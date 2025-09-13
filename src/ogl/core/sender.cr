require "socket"

require "./common/protocol"
require "./common/conn"
require "./common/op"
require "./common/util"
require "./common/message"

module OGL::Core
  class Sender
    def initialize(@host : String, @port : Int32); end

    def send_to(target_id : Int64, text : String) : Bool
      sock = TCPSocket.new @host, @port
      return false unless Protocol.handshake_agent(sock)
      
      conn = Conn.new sock

      buf = IO::Memory.new
      buf.write OGL::Util.u64_be(target_id.to_u64)  # 8 bytes
      buf.write text.to_slice
      env = buf.to_slice

      conn.send_msg Message.new(Op::Route, env)
      conn.close
      true
    rescue
      false
    end
  end
end
