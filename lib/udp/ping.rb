# frozen_string_literal: true

module Udp
  class Ping < Packet
    attr_accessor :users_count, :max_bandwidth, :max_users, :ident

    def self.encode(msg)
      buffer = StringIO.new.binmode
      msg.encode(buffer)
      buffer.string
    end

    def legacy?
      true
    end

    def bytesize
      12
    end

    def encode(stream)
      stream.write(0)
      stream.write(1)
      stream.write(3)
      stream.write(4)
      stream.write(@ident)
      stream.write([@users_count].pack('N'))
      stream.write([@max_users].pack('N'))
      stream.write([@max_bandwidth].pack('N'))
    end
  end
end
