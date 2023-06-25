# frozen_string_literal: true

module Messages
  module Factory
    class ServerConfig < Registry[:server_config]
      def call(_input)
        Proto::Mumble::ServerConfig.new(app.config)
      end
    end
  end
end
