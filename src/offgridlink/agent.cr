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
      if bytes = conn.recv_frame
        puts "Server: #{String.new(bytes)}"
      end

      conn.send_frame "PONG"
      conn.close
    end
  end
end
