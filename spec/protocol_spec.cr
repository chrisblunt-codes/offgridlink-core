# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "spec"

require "../src/offgridlink/common/protocol" # MAGIC/VERSION + your handshake helpers


require "spec"
require "socket"
require "../src/offgridlink/common/protocol"

describe "Protocol handshake" do
  it "completes server<->agent over TCP" do
    server = TCPServer.new "127.0.0.1", 0
    port   = server.local_address.port
    srv_ok = Channel(Bool).new

    # server fiber
    spawn do
      if sock = server.accept?
        sock.read_timeout  = 1.second
        sock.write_timeout = 1.second
        ok = OGL::Protocol.handshake_server(sock)  # returns Bool
        sock.close
        srv_ok.send(ok)
      else
        srv_ok.send(false)
      end
    end

    # client
    client = TCPSocket.new "127.0.0.1", port
    client.read_timeout  = 1.second
    client.write_timeout = 1.second
    cli_ok = OGL::Protocol.handshake_agent(client) # returns Bool
    client.close

    server.close
    srv_ok.receive.should be_true
    cli_ok.should be_true
  end

  it "rejects when agent replies with a wrong version" do
    server = TCPServer.new "127.0.0.1", 0
    port   = server.local_address.port
    srv_ok = Channel(Bool).new

    # Server fiber: run handshake_server and report result
    spawn do
      if sock = server.accept?
        sock.read_timeout  = 1.second
        sock.write_timeout = 1.second
        ok = OGL::Protocol.handshake_server(sock)  # should be false
        sock.close
        srv_ok.send(ok)
      else
        srv_ok.send(false)
      end
    end

    # "Bad" agent: read server prelude, then send MAGIC + bad VERSION
    client = TCPSocket.new "127.0.0.1", port
    client.read_timeout  = 1.second
    client.write_timeout = 1.second

    buf = Bytes.new(5)                              # 4 magic + 1 version
    client.read_fully(buf)                          # read server prelude
    client.write OGL::Protocol::MAGIC.to_slice      # echo magic
    client.write_byte 0xFF_u8                       # WRONG version
    client.flush
    client.close

    server.close
    srv_ok.receive.should be_false
  end

  it "rejects when agent replies with a wrong magic" do
    server = TCPServer.new "127.0.0.1", 0
    port = server.local_address.port
    srv_ok = Channel(Bool).new

    # Server fiber
    spawn do
      if sock = server.accept?
        sock.read_timeout  = 1.second
        sock.write_timeout = 1.second
        ok = OGL::Protocol.handshake_server(sock)  # should be false
        sock.close
        srv_ok.send(ok)
      else
        srv_ok.send(false)
      end
    end

    # Bad agent: read server prelude, then send WRONG magic + correct version
    client = TCPSocket.new "127.0.0.1", port
    client.read_timeout  = 1.second
    client.write_timeout = 1.second

    buf = Bytes.new(5)                            # read "OGL1" + version
    client.read_fully(buf)
    client.write "NOGL".to_slice                  # wrong 4-byte magic
    client.write_byte OGL::Protocol::VERSION      # (even with correct version)
    client.flush
    client.close

    server.close
    srv_ok.receive.should be_false
  end

end
