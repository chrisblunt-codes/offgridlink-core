# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/conn"
require "./common/op"

module OGL
  class Server
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
        conn = Conn.new sock
        conn.send_msg Message.new(Op::Hello, "HELLO".to_slice)
        while msg  = conn.recv_msg_obj
          if h = @handlers[msg.op]?
            h.call msg
          else
            puts "Unhandled message: #{msg.op} #{msg.string}"
          end
        end
        conn.close
      end
    end
  end
end