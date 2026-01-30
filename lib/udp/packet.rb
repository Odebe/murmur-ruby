# frozen_string_literal: true

module Udp
  class Packet
    attr_accessor :sender_sockaddr

    def legacy?
      false
    end

    def clone_for_target(target_sockaddr)
      copy = clone
      copy.sender_sockaddr = target_sockaddr
      copy
    end
  end
end
