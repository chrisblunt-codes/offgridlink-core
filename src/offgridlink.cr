# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "option_parser"

require "./offgridlink/version"
require "./offgridlink/common/op"
require "./offgridlink/server"
require "./offgridlink/agent"
require "./offgridlink/sender"


module OGL
  def self.run
    mode : Symbol? = nil
    addr = "127.0.0.1"
    port = 7000
    to   = 0_i64
    msg  = ""

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

      p.on("send", "Send a message to a specific client id") do
        mode = :send
        p.on("--addr HOST", "Server address") { |v| addr = v }
        p.on("--port PORT", "Server port")    { |v| port = v.to_i }
        p.on("--to ID", "Target client id")   { |v| to   = v.to_i64 }
        p.unknown_args do |args|
          msg = args.join(" ")
        end
      end

      p.on("-h", "--help", "Show help") do
        puts p
        exit 0
      end
    end

    parser.parse

    case mode
    when :server then run_server(port)
    when :agent  then Agent.new(addr, port).run_forever
    when :send   then send_message(addr, port, to, msg)
    else
      puts "Unknown command"
      puts parser
      exit 1
    end
  end

  def self.run_server(port : Int32)
    srv = Server.new(port)
    srv.on(Op::Hello) { |m| puts "HELLO from agent: #{m.string}" }
    srv.on(Op::Pong)  { |m| puts "PONG from agent: #{Time.utc}" }
    srv.on(Op::Data)  { |m| puts "DATA #{m.string.bytesize}B '#{m.string}'" }
    srv.run
  end

  def self.send_message(addr : String, port : Int32, to : Int64, msg : String)
    if to < 0 || msg.empty?
      STDERR.puts "Usage: offgridlink send --to <id> [--addr HOST --port PORT] <message>"
      exit 1
    end

    if Sender.new(addr, port).send_to(to, msg)
      puts "Message sent" 
      exit 0
    else 
      puts "Failed to send message" 
      exit 1
    end
  end
end

OGL.run
