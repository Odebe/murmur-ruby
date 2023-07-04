# frozen_string_literal: true

module Actions
  module Incoming
    class Version < Dispatch[::Proto::Mumble::Version]
      def handle(message)
        app.db.clients.set_version(client[:session_id], message)

        # TODO: send server version
        reply message
      end
    end
  end
end
