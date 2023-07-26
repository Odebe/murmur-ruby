# frozen_string_literal: true

module Actions
  module Incoming
    class UdpTunnel < Dispatch[TcpAction, ::Proto::Mumble::UDPTunnel]
      def handle
        authorize!
        halt! if client[:self_mute]

        udp_packet = ::Voice::Decoder.read_decrypted(message.packet)
        udp_packet.session_id = client[:session_id]

        # udp_packet.size + protobuf header size
        halt! unless client[:traffic_shaper].check!(udp_packet.size + 6)

        # adding session_id to packet
        # buffer = StringIO.new.binmode
        # stream = ::VarintStream.new(buffer)
        # udp_packet.encode(stream)

        message = Proto::Mumble::UDPTunnel.new(
          packet: ::Voice::Decoder.encode(udp_packet)
        )

        # TODO: constants
        # TODO: use UDP for clients with UDP
        case udp_packet.header_target
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
