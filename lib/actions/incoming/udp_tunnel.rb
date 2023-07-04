# frozen_string_literal: true

module Actions
  module Incoming
    class UdpTunnel < Dispatch[::Proto::Mumble::UDPTunnel]
      def handle(message)
        authorize!

        packet = ::Client::VoicePacket.new(message.packet)
        msg    = ::Proto::Mumble::UDPTunnel.new(packet: packet.to_outgoing(session_id: client[:session_id]))

        # TODO: constants
        case packet.target
        when 31
          # Loopback
          reply msg
        else
          # Ignoring voice targets, send packet to current channel
          db.clients.in_room(client[:room_id], except: [client[:session_id]]).each do |room_client|
            post msg, to: room_client
          end
        end
      end
    end
  end
end
