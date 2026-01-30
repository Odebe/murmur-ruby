# frozen_string_literal: true

module Udp
  class RawPacket
    attr_reader :data, :sender_sockaddr

    def initialize(data, sender_sockaddr)
      @data = data
      @sender_sockaddr = sender_sockaddr
    end

    def legacy?
      false
    end
  end
end
