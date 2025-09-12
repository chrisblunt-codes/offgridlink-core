# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/protocol"
require "./common/conn"
require "./common/op"

module OGL
  class Server
    KEEPALIVE = 15.seconds
    IDLE_KILL = 45.seconds


    alias Handler = Proc(Message, Nil)

    def initialize(@port : Int32)
      @handlers = {} of Op => Handler
    end

    def on(op : Op, &block : Message ->)
      @handlers[op] = block
    end

    def run
      srv = TCPServer.new "0.0.0.0", @port
      puts "Listening on #{@port}"
      if sock = srv.accept?
        return unless Protocol.handshake_server(sock)

        conn = Conn.new sock

        # greet once
        conn.send_msg Message.new(Op::Hello, "HELLO".to_slice)
        
        # ping/timeout fiber
        spawn do
          loop do
            sleep KEEPALIVE
            if conn.last_rx > KEEPALIVE
              conn.send_msg Message.new(Op::Ping, Bytes.empty)
            end
            if conn.last_rx > IDLE_KILL
              puts "idle timeout; closing"
              conn.close
              break
            end
          end
        end

        # receive loop
        while msg = conn.recv_msg_obj
          case msg.op
          when Op::Pong
            puts "PONG (latency ok)"
          when Op::Data
            puts "DATA #{msg.string.bytesize}B '#{msg.string}'"
          else
            puts "unhandled #{msg.op}"
          end
        end

        conn.close
      end
    end

  end
end