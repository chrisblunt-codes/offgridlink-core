# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/protocol"
require "./common/conn"
require "./common/util"


module OGL
  class Agent
    def initialize(@host : String, @port : Int32); end

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

          case msg.op
          when Op::Hello
            conn.send_msg Message.new(Op::Hello, "OK".to_slice)
          when Op::AssignId
            @id = Util.be_u64(msg.payload)
            puts "assigned id=#{@id}"
          when Op::Ping
            conn.send_msg Message.new(Op::Pong, Bytes.empty)
          when Op::Cmd, Op::Data
            # handle as needed; for now just log
            puts "server #{msg.op}: #{msg.string}"
          else
            # ignore unknowns for now
          end
        rescue IO::Error
          # timeout / broken pipe / reset, etc.
          break
        end
      end

      conn.close rescue nil
    end

  end
end
