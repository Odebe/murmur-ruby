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
          db.clients.listeners(client[:room_id], except: [client[:session_id]]).each do |listener|
            post message, to: listener
          end
        end
      end
    end
  end
end
