# frozen_string_literal: true

module Actions
  module Udp
    module Encrypted
      # TODO: remove code duplication
      class Audio < Dispatch[UdpAction, ::Udp::Wrappers::Audio]
        def handle
          app.db.clients.update(client, udp_used: true)
          app.db.clients.set_udp_listener(client)

          halt! if client.self_mute
          halt! unless client.traffic_shaper.check!(wrapped_message.bytesize)

          # Setting context will set the target field to 0
          message_target = message.target

          message.context = 0
          message.sender_session = client.session_id

          # TODO: constants
          case message_target
          when 31
            # Loopback
            reply message
          else
            # Ignoring voice targets, send packet to current channel
            # TODO: implement voice targets
            db.clients.udp_listeners(client.room_id).each do |listener|
              next if listener.eql?(client)

              send_udp message, to: listener
            end

            db.clients.tcp_listeners(client.room_id).each do |listener|
              next if listener.eql?(client)

              send_tcp message, to: listener
            end
          end
        end
      end
    end
  end
end
