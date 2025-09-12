# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/conn"

module OGL
  class Agent
    def initialize(@host : String, @port : Int32); end

    def run
      sock = TCPSocket.new @host, @port
      conn = Conn.new sock
      if msg = conn.recv_msg_obj
        puts "Server: #{msg.op} #{String.new(msg.payload)}"
      end

      conn.send_msg Message.new(Op::Pong, "Pong".to_slice)
      conn.send_msg Message.new(Op::Data, "Hi from agent".to_slice)
      conn.close
    end
  end
end
