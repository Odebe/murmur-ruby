# frozen_string_literal: true

module Actions
  module Udp
    class Ping < Dispatch[UdpAction, ::Udp::Ping]
      def handle
        message.users_count   = app.db.clients.all.count
        message.max_bandwidth = app.config.max_bandwidth
        message.max_users     = app.config.max_users

        reply message
      end
    end
  end
end
