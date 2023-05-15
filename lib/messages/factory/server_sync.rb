# frozen_string_literal: true

module Messages
  module Factory
    class ServerSync < Registry[:server_sync]
      def call(input)
        Proto::Mumble::ServerSync.new(
          session: input[:user_id],
          max_bandwidth: settings[:max_bandwidth],
          welcome_text: settings[:welcome_text],
          permissions: 1
        )
      end
    end
  end
end
