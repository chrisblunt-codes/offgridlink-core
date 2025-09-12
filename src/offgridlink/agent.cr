# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/protocol"
require "./common/conn"

module OGL
  class Agent
    def initialize(@host : String, @port : Int32); end

    def run
      sock = TCPSocket.new @host, @port
      return unless Protocol.handshake_agent(sock)

      conn = Conn.new sock

      while msg = conn.recv_msg_obj
        case msg.op
        when Op::Hello
          puts "server hello: #{msg.string}"
          conn.send_msg Message.new(Op::Pong, "PONG".to_slice)
        when Op::Ping
          conn.send_msg Message.new(Op::Pong, Bytes.empty)
        when Op::Cmd, Op::Data
          puts "server #{msg.op}: #{msg.string}"
        else
          # ignore for now
        end
      end
      
      conn.close
    end
  end
end
