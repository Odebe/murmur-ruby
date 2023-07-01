# frozen_string_literal: true

module Actions
  module Incoming
    class Authenticate < Dispatch[::Proto::Mumble::Authenticate]
      def handle(message)
        if app.db.clients.count >= app.config[:max_users]
          reply build(:server_reject, reason: :ServerFull)
          disconnect!(:auth_error)
          throw(:halt)
        end

        if app.db.clients.by_name(message.username)
          reply build(:server_reject, reason: :UsernameInUse)
          disconnect!(:auth_error)
          throw(:halt)
        end

        registered_user = app.db.users.by_name(message.username)
        if registered_user && registered_user[:password] != message.password
          reply build(:server_reject, reason: :WrongServerPW)
          disconnect!(:auth_error)
          throw(:halt)
        end

        if message.username.size == 0 || message.username.size > app.config[:max_username_length]
          reply build(:server_reject, reason: :InvalidUsername)
          disconnect!(:auth_error)
          throw(:halt)
        end

        app.db.clients.set_auth(client[:session_id], message)
        app.db.clients.update(client[:session_id], user_id: registered_user[:id]) if registered_user

        build(:all_channels).each { |state| reply state }
        build(:authorized_clients).each { |state| reply state }

        reply build(:user_state, client: client)
        reply build(:server_sync, client: client)

        client_state = build(:user_state, client: client)
        app.db.clients.authorized.each { |client| post client_state, to: client }

        reply build(:server_config)
      end
    end
  end
end
