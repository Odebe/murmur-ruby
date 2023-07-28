# frozen_string_literal: true

module Actions
  module Voice
    class Opus < Dispatch[UdpAction, ::Voice::Packet::Opus]
      def handle
        authorize!

        message.session_id = client[:session_id]

        halt! unless client[:traffic_shaper].check!(message.size)

        case message.header_target
        when 31
          # Loopback
          reply message
        else
          # Ignoring voice targets, send packet to current channel
          listeners = db.clients.listeners(client[:room_id], except: [client[:session_id]])
          tcp, udp  = listeners.partition { |l| l[:udp_address].nil? }

          udp.each { |listener| post_voice message, to: listener } if udp.any?

          if tcp.any?
            proto = Proto::Mumble::UDPTunnel.new(packet: ::Voice::Decoder.encode(message))

            udp.each { |listener| post proto, to: listener }
          end
        end
      end
    end
  end
end
