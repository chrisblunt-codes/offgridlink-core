# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

require "./frame"

module OGL
  class Conn
    getter io : IO

    def initialize(@io : IO); end

    def send_msg(op : Op, s : String)
      send_msg(op, s.to_slice)
    end

    def send_msg(op : Op, bytes : Bytes)
      Frame.write_msg(io, op, bytes)
    end

    def send_frame(s : String)
      send_frame s.to_slice
    end

    def send_frame(bytes : Bytes)
      Frame.write(io, bytes)
    end

    def recv_msg : {Op, Bytes}?
      Frame.read_msg(io)
    end
    
    def recv_frame : Bytes?
      Frame.read(io)
    end

    def send_line(s : String)
      io << s << "\n"
      io.flush
    end

    def recv_line : String?
      io.gets.try &.chomp
    end

    def close
      io.close
    end
  end
end