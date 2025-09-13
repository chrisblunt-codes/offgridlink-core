# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "socket"

module OGL::Core
  class Frame
    # write: [u32_be len][u8 op][payload]
    def self.write_msg(io : IO, op : Op, payload : Bytes)
      buf = Bytes.new(1 + payload.size)
      buf[0] = op.to_u8
      buf[1, payload.size].copy_from(payload)
      write(io, buf)
    end

    # read: returns {op, payload} or nil on EOF
    def self.read_msg(io : IO) : {Op, Bytes}?
      return nil unless (buf = read(io))
      { Op.from_value(buf[0]), buf[1, buf.size - 1] }
    end

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