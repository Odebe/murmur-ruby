# frozen_string_literal: true

module Udp
  module Wrappers
    def self.wrap(message, bytesize:, sender_sockaddr: nil, client: nil, source: :udp)
      klass =
        case message
        when ::Proto::MumbleUdp::Ping
          Ping
        when ::Proto::MumbleUdp::Audio
          Audio
        when ::Udp::Ping
          LegacyPing
        else
          raise "Unknown message type: #{message.class}"
        end

      klass.new(
        message,
        bytesize: bytesize,
        sender_sockaddr: sender_sockaddr,
        client: client,
        source: source
      )
    end
  end
end
