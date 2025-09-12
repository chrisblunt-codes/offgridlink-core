# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./common/protocol"
require "./common/conn"
require "./common/op"
require "./common/util"

module OGL
  class Server
    KEEPALIVE = 15.seconds
    IDLE_KILL = 45.seconds


    alias Handler = Proc(Message, Nil)

    def initialize(@port : Int32)
      @handlers = {} of Op => Handler
      @clients  = {} of Int64 => Conn
      @lock     = Mutex.new
      @next_id  = Atomic(Int64).new(1_i64)
    end

    def on(op : Op, &block : Message ->)
      @handlers[op] = block
    end

    def broadcast(op : Op, s : String)
      @lock.synchronize do
        @clients.each_value { |c| c.send_msg Message.new(op, s.to_slice) }
      end
    end

    def run
      srv = TCPServer.new "0.0.0.0", @port
      puts "Listening on #{@port}"
    
      loop do
        if sock = srv.accept?
          sock.write_timeout = 2.seconds
          # Let the handler run in its own fiber
          spawn handle_client(sock)
        end
      end
    end

    def handle_client(sock : TCPSocket)
      unless Protocol.handshake_server(sock)
        sock.close
        return
      end

      id = @next_id.add(1) - 1
      conn = Conn.new sock
      @lock.synchronize { @clients[id] = conn }
      puts "client ##{id} connected"

      conn.send_msg Message.new(Op::AssignId, OGL::Util.u64_be(id.to_u64))
      conn.send_msg Message.new(Op::Hello, "HELLO".to_slice)

      # keepalive / idle-timeout
      ka = spawn do
        loop do
          sleep KEEPALIVE

          break if conn.closed?
          if conn.last_rx > KEEPALIVE
            conn.send_msg Message.new(Op::Ping, Bytes.empty)
          end
          if conn.last_rx > IDLE_KILL
            puts "##{id} idle timeout; closing"
            conn.close
            break
          end
        end
      end

      # receive/dispatch loop
      while msg = conn.recv_msg_obj
        if h = @handlers[msg.op]?
          h.call msg
        else
          puts "##{id} unhandled #{msg.op}: #{msg.string}"
        end
      end
    rescue IO::Error
      # connection dropped; fall through to cleanup
    ensure
      conn.try &.close
      @lock.synchronize { @clients.delete(id) }
      puts "client ##{id} disconnected"
    end

    def send_to(id : Int64, op : Op, s : String)
      @lock.synchronize do
        if c = @clients[id]?
          c.send_msg Message.new(op, s.to_slice)
        end
      end
    end
  end
end