# frozen_string_literal: true

module Actions
  module Incoming
    class Ping < Dispatch[::Proto::Mumble::Ping]
      def handle(message)
        reply Proto::Mumble::Ping.new(timestamp: message.timestamp)
      end
    end
  end
end
