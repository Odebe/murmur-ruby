# frozen_string_literal: true

module Actions
  module Incoming
    class Ping < Dispatch[::Proto::Mumble::Ping]
      def handle(message)
        reply build(:ping, timestamp: message.timestamp)
      end
    end
  end
end
