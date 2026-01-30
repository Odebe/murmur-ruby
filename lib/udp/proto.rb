# frozen_string_literal: true

module Udp
  class Proto < Packet
    attr_accessor :proto_message

    def clone_for_target(target_sockaddr)
      copy = super
      copy.proto_message = proto_message
      copy
    end
  end
end
