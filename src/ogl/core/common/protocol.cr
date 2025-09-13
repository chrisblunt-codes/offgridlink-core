# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

module OGL::Core
  module Protocol
    MAGIC   = "OGL1"    # 4-byte ASCII tag
    VERSION = 1_u8      # protocol version


    def self.handshake_server(io : IO) : Bool
      io.write Protocol::MAGIC.to_slice
      io.write_byte Protocol::VERSION
      io.flush

      client_magic = Bytes.new(4)
      io.read_fully client_magic
      client_ver   = io.read_byte

      magic_str = String.new(client_magic.to_slice)

      unless magic_str == Protocol::MAGIC && client_ver == Protocol::VERSION
        puts "bad handshake; closing"
        io.close
        return false
      end

      true
    rescue e : IO::Error
      puts e
      e.backtrace.each { |l| puts l }
      false
    end

    def self.handshake_agent(io : IO) : Bool
      server_magic = Bytes.new(4)
      io.read_fully server_magic
      server_ver = io.read_byte

      magic_str = String.new(server_magic.to_slice)

      unless magic_str == Protocol::MAGIC && server_ver == Protocol::VERSION
        puts "incompatible server"
        io.close
        return false
      end

      io.write Protocol::MAGIC.to_slice
      io.write_byte Protocol::VERSION
      io.flush
    
      true

    rescue e : IO::Error
      e.backtrace.each { |l| puts l }
      puts e
      
      false
    end
  end
end