# frozen_string_literal: true

module Messages
  module Factory
    class ServerSync < Registry[:server_sync]
      def call(input)
        Proto::Mumble::ServerSync.new(
          session: input[:session_id],
          permissions: Acl.granted_permissions(input[:user], nil)
        )
      end
    end
  end
end
