# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "option_parser"

require "./offgridlink/version"
require "./offgridlink/server"
require "./offgridlink/agent"


module OGL
  def self.run
    mode : Symbol? = nil
    addr = "127.0.0.1"
    port = 7000

    parser = OptionParser.new do |p|
      p.banner = "Usage: offgridlink [command] [options]"

      p.on("server", "Run as server") do
        mode = :server
        p.on("--port PORT", "Listen port (default: 7000)") { |v| port = v.to_i }
      end

      p.on("agent", "Run as agent") do
        mode = :agent
        p.on("--addr HOST", "Server address (default: 127.0.0.1)") { |v| addr = v }
        p.on("--port PORT", "Server port (default: 7000)")         { |v| port = v.to_i }
      end

      p.on("-h", "--help", "Show help") do
        puts p
        exit 0
      end
    end

    parser.parse

    if mode.nil?
      puts parser
      exit 1
    end

    case mode
    when :server then Server.new(port).run
    when :agent  then Agent.new(addr, port).run
    end
  end
end

OGL.run
