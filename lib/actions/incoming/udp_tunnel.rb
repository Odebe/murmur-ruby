# frozen_string_literal: true

module Actions
  module Incoming
    class UdpTunnel < Dispatch[::Proto::Mumble::UDPTunnel]
      def handle
        authorize!
        halt! if client[:self_mute]

        buffer     = StringIO.new(message.packet).binmode
        udp_stream = Client::VoiceStream.new(buffer)

        udp_packet = Client::VoicePacket.new(client[:session_id])

        udp_packet.decode_from(udp_stream)
        buffer.rewind
        # adding session_id to packet
        udp_packet.encode_to(udp_stream)

        message = Proto::Mumble::UDPTunnel.new(packet: buffer.string)

        # TODO: constants
        case udp_packet.target
        when 31
          # Loopback
          reply message
        else
          # Ignoring voice targets, send packet to current channel
          db.clients.listeners(client[:room_id], except: [client[:session_id]]).each do |listener|
            post message, to: listener
          end
        end
      end
    end
  end
end
