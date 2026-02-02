# frozen_string_literal: true

module Udp
  class EncryptedPacket < Packet
    attr_accessor :data

    def bytesize
      data.bytesize
    end
  end
end
