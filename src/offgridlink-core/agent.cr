# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/protocol"
require "./common/conn"
require "./common/backoff"
require "./common/util"


module OGL
  class Agent
    def initialize(@host : String, @port : Int32)
      @tunnel : TCPSocket?
    end

    def run
      sock = TCPSocket.new @host, @port
      sock.write_timeout = 2.seconds
      unless Protocol.handshake_agent(sock)
        puts "handshake failed"
        sock.close
        return
      end

      conn = Conn.new sock

      # stay alive and respond to pings/commands
      loop do
        begin
          msg = conn.recv_msg_obj
          break unless msg # EOF -> server closed

          process_msg(conn, msg)
        rescue IO::Error
          # timeout / broken pipe / reset, etc.
          break
        end
      end

      conn.close rescue nil
    end

    def run_forever
      attempt = 0
      loop do
        if connect_and_serve
          attempt = 0  # clean exit -> reset backoff
        else
          attempt += 1
          sleep OGL::Backoff.next_delay(attempt)
        end
      end
    end

    private def connect_and_serve : Bool
      sock = TCPSocket.new @host, @port
      return false unless Protocol.handshake_agent(sock)

      conn = Conn.new sock
      loop do
        msg = conn.recv_msg_obj || break
        process_msg(conn, msg)
      end
      conn.close rescue nil
      true
    rescue Socket::Error | IO::Error
      false
    end

    private def process_msg(conn : Conn, msg : Message)
      case msg.op
      when Op::Hello         then conn.send_msg Message.new(Op::Hello, "OK".to_slice)
      when Op::AssignId      then @id = Util.be_u64(msg.payload)
      when Op::Ping          then conn.send_msg Message.new(Op::Pong, Bytes.empty)
      when Op::Cmd, Op::Data then puts "server #{msg.op}: #{msg.string}"
      when Op::TunnelOpen    then open_tunnel(msg.string, conn)
      else
        # ignore unknowns for now
      end
    end

    private def open_tunnel(dest : String, conn : Conn)
      host, port_str = dest.split(":", 2)
      port = port_str.to_i

      @tunnel = TCPSocket.new(host, port)
    rescue e
      # If open fails, tell server we're done with this attempt
      conn.send_msg Message.new(Op::TunnelClose, Bytes.empty)
    end
  end
end
