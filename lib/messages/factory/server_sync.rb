# frozen_string_literal: true

module Messages
  module Factory
    class ServerSync < Registry[:server_sync]
      def call(_input)
        Proto::Mumble::ServerSync.new(
          session:       client[:session_id],
          permissions:   Acl.granted_permissions(client, nil),
          max_bandwidth: app.config[:max_bandwidth]
        )
      end
    end
  end
end
