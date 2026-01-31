# frozen_string_literal: true

module Actions
  module Udp
    module Encrypted
      class Audio < Dispatch[UdpAction, ::Udp::Wrappers::Audio]
        def handle
          app.db.clients.update(client[:session_id], udp_used: true, udp_address: sender_addr)

          # TODO: reimplement, pass data size to wrapped_message
          # halt! unless client[:traffic_shaper].check!(udp_packet.size + 6)

          # Setting context will set the target field to 0
          message_target = message.target

          message.context = 0
          message.sender_session = client[:session_id]

          # TODO: constants
          case message_target
          when 31
            # Loopback
            reply message
          else
            # Ignoring voice targets, send packet to current channel
            listeners = db.clients.listeners(client[:room_id], except: [client[:session_id]])
            udp, tcp  = listeners.partition { |l| l[:udp_used].nil? }

            tcp.each { |listener| send_tcp message, to: listener } if tcp.any?
            udp.each { |listener| send_udp message, to: listener } if udp.any?
          end
        end
      end
    end
  end
end
