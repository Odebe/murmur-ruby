# frozen_string_literal: true

module Actions
  module Incoming
    class UserState < Dispatch[::Proto::Mumble::UserState]
      def handle(message)
        authorize!

        reply message
      end
    end
  end
end
