# frozen_string_literal: true

module Messages
  module Factory
    class ServerConfig < Registry[:server_config]
      VALUES = %i[
        max_bandwidth
        welcome_text
        allow_html
        message_length
        image_message_length
        max_users
        recording_allowed
      ].freeze

      def call(_input)
        hash = VALUES.each_with_object({}) { |e, acc| acc[e] = app.config.public_send(e) }
        Proto::Mumble::ServerConfig.new(hash)
      end
    end
  end
end
