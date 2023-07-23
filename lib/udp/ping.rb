# frozen_string_literal: true

module Udp
  class Ping < Packet
    attr_accessor :users_count, :max_bandwidth, :max_users

    def decode(stream)
      @ident = stream.read(8)
    end

    def raw
      @ident
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
