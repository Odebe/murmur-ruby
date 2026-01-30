# frozen_string_literal: true

module Actions
  module Udp
    class Encrypted
      class Audio < Dispatch[UdpAction, Proto::MumbleUdp::Audio]
        def handle
          message.context = 0
          message.sender_session = client[:session_id]

          # TODO: implement properly

          reply message
        end
      end
    end
  end
end
