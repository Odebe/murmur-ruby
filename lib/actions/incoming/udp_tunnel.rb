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

        message = Proto::Mumble::UDPTunnel.new(packet: ::Voice::Decoder.encode(udp_packet))

        # TODO: constants
        # TODO: use UDP for clients with UDP
        case udp_packet.header_target
        when 31
          # Loopback
          reply message
        else
          # Ignoring voice targets, send packet to current channel
          listeners = db.clients.listeners(client[:room_id], except: [client[:session_id]])
          tcp, udp  = listeners.partition { |l| l[:udp_address].nil? }

          tcp.each { |listener| post message, to: listener } if tcp.any?
          udp.each { |listener| post_voice udp_packet, to: listener } if udp.any?
        end
      end
    end
  end
end
