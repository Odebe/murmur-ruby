# frozen_string_literal: true

module Actions
  module Incoming
    class Authenticate < Dispatch[::Proto::Mumble::Authenticate]
      def handle(message)
        app.db.clients.set_auth(client[:session_id], message)

        build(:all_channels).each { |state| reply state }
        build(:all_clients).each { |state| reply state }

        reply build(:server_sync, session_id: client[:session_id])

        client_state = build(:user_state, client: client)
        app.db.clients.all.each { |client| post client_state, to: client }

        reply build(:server_config)
      end
    end
  end
end
