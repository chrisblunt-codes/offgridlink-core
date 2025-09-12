# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

enum Op : UInt8
  # control channel (0x00–0x1F)
  Hello     = 0x01
  Ping      = 0x02
  Pong      = 0x03
  AssignId  = 0x04
  Route     = 0x05  # [u64_be target_id][payload] -> server forwards to target
  Error     = 0x0F

  # data channel (0x20–0x3F)
  Data      = 0x20
  File      = 0x21
  Cmd       = 0x22

  # tunnel channel (0x40–0x5F)
  TunnelOpen  = 0x40
  TunnelData  = 0x41
  TunnelClose = 0x42
  TunnelErr   = 0x43

  # reserved for future (0x60+)
end
