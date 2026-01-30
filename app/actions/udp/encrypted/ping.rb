# frozen_string_literal: true

module Actions
  module Udp
    class Encrypted
      class Ping < Dispatch[UdpAction, Proto::MumbleUdp::Ping]
        def handle
          if message.request_extended_information
            message.server_version_v2 = ::Version::SUPPORTED_PROTOCOL_VERSION_V2
            message.users_count   = app.db.clients.all.count
            message.max_bandwidth = app.config.max_bandwidth
            message.max_users     = app.config.max_users
          end

          reply message
        end
      end
    end
  end
end
