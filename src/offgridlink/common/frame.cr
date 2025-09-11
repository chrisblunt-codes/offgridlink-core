# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

module OGL
  class Frame
    # write: [u32_be length][payload]
    def self.write(io : IO, payload : Bytes)
      io.write_bytes(payload.size.to_u32, IO::ByteFormat::BigEndian)
      io.write payload  
      io.flush
    end

    # read: returns Bytes or nil on EOF
    def self.read(io : IO) : Bytes?
      len = io.read_bytes(UInt32, IO::ByteFormat::BigEndian) rescue return nil
      buf = Bytes.new(len)
      io.read_fully(buf) rescue return nil
      buf
    end
  end
end