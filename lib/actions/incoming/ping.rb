# frozen_string_literal: true

module Actions
  module Incoming
    class Ping < Dispatch[::Proto::Mumble::Ping]
      def handle
        reply message
      end
    end
  end
end
