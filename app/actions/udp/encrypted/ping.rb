# frozen_string_literal: true

module Actions
  module Udp
    module Encrypted
      class Ping < Dispatch[UdpAction, ::Udp::Wrappers::Ping]
        def handle
          unless client.udp_used
            app.db.clients.set_udp_used(client, true)
            app.db.clients.set_udp_listener(client)
          end

          if message.request_extended_information
            message.server_version_v2 = ::Version::SUPPORTED_PROTOCOL_VERSION_V2
            message.users_count   = app.db.clients.count
            message.max_bandwidth = app.config.max_bandwidth
            message.max_users     = app.config.max_users
          end

          reply message
        end
      end
    end
  end
end
