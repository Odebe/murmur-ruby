# frozen_string_literal: true

module Actions
  module Incoming
    class Version < Dispatch[::Proto::Mumble::Version]
      def handle(message)
        users.set_version(user_id, message)
      end
    end
  end
end
