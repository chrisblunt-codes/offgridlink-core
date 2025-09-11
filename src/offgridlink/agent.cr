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
      puts "Server: #{conn.recv_line}"
      conn.send_line "PONG"
      conn.close
    end
  end
end
