# frozen_string_literal: true

module Messages
  module Factory
    class Ping < Registry[:ping]
      def call(input)
        Proto::Mumble::Ping.new(timestamp: input[:timestamp])
      end
    end
  end
end
