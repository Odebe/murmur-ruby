# frozen_string_literal: true

module Udp
  class Packet
    attr_accessor :sender_sockaddr

    def legacy?
      false
    end
  end
end
