# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "../src/offgridlink-core"

srv = OGL::Core::Server.new(port: 7000)
srv.on(OGL::Core::Op::Hello) { |m| puts "HELLO from agent: #{m.string}" }
srv.on(OGL::Core::Op::Pong)  { |m| puts "PONG from agent: #{Time.utc}" }
srv.on(OGL::Core::Op::Data)  { |m| puts "DATA #{m.string.bytesize}B '#{m.string}'" }
srv.run