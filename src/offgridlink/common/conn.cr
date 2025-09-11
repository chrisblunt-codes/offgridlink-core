# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

module OGL
  class Conn
    getter io : IO

    def initialize(@io : IO); end

    def send_line(s : String)
      io << s << "\n"
      io.flush
    end

    def recv_line : String ?
      io.gets.try &.chomp
    end

    def close
      io.close
    end
  end
end