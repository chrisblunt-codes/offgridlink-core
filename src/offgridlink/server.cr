# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/conn"
require "./common/op"

module OGL
  class Server
    def initialize(@port : Int32)
      @srv = TCPServer.new "0.0.0.0", @port
    end

    def run
      puts "listening on #{@port}"
      if conn = accept_once

        conn.send_msg Op::Hello, "hello"

        if tuple = conn.recv_msg
          op, bytes = tuple
          puts "got: #{op} #{String.new(bytes)}"
        end
        conn.close
      end
    end

    def accept_once : Conn?
      if sock = @srv.accept?
        puts "agent: #{sock.remote_address}"
        Conn.new sock
      end
    end
  end
end