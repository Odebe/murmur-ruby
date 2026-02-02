# frozen_string_literal: true

module Responses
  module Factory
    class Ping < Registry[:ping]
      def call(input)
        Proto::Mumble::Ping.new(timestamp: input[:timestamp])
      end
    end
  end
end
