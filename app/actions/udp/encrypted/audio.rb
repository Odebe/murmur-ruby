# frozen_string_literal: true

module Actions
  module Udp
    class Encrypted
      class Audio < Dispatch[UdpAction, Proto::MumbleUdp::Audio]
        def handle
          # TODO: handle audio
          puts "audio received: #{message.inspect}"
        end
      end
    end
  end
end
