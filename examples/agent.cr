# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "../src/offgridlink-core"

OGL::Core::Agent.new(host: "127.0.0.1", port: 7000).run