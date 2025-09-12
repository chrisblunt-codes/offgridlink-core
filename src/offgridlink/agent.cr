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
      if tuple = conn.recv_msg
        op, bytes = tuple
        puts "Server: #{op} #{String.new(bytes)}"
      end

      conn.send_msg Op::Pong, "PONG"
      conn.close
    end
  end
end
