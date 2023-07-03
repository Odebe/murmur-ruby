# frozen_string_literal: true

module Actions
  module Incoming
    class UdpTunnel < Dispatch[::Proto::Mumble::UDPTunnel]
      def handle(message)
        packet = ::Client::VoicePacket.new(message.packet)
        msg    = ::Proto::Mumble::UDPTunnel.new(packet: packet.to_outgoing(session_id: client[:session_id]))

        reply msg
      end
    end
  end
end
