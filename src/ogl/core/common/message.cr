# Copyright 2025 Chris Blunt
# Licensed under the Apache License, Version 2.0

require "./op"

module OGL::Core
  class Message
    getter op       : Op
    getter payload  : Bytes
    

    def initialize(@op : Op, @payload : Bytes)
    end

    def string : String
      String.new(payload)
    end
  end
end