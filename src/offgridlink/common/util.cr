# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

module OGL::Util
  def self.u64_be(n : UInt64) : Bytes
    b = Bytes.new(8)
    8.times { |i| b[i] = ((n >> (56 - i*8)) & 0xFF).to_u8 }
    b
  end

  def self.be_u64(b : Bytes) : UInt64
    raise "need 8 bytes" unless b.size >= 8
    v = 0_u64; 8.times { |i| v = (v << 8) | b[i].to_u64 }; v
  end
end
