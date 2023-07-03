# frozen_string_literal: true

module Actions
  module Incoming
    class Authenticate < Dispatch[::Proto::Mumble::Authenticate]
      def handle(message)
        if db.clients.count >= app.config[:max_users]
          reply build(:server_reject, reason: :ServerFull)
          disconnect!(:auth_error)
          throw(:halt)
        end

        if db.clients.by_name(message.username)
          reply build(:server_reject, reason: :UsernameInUse)
          disconnect!(:auth_error)
          throw(:halt)
        end

        registered_user = db.users.by_name(message.username)
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

        db.clients.set_auth(client[:session_id], message)
        db.clients.update(client[:session_id], user_id: registered_user[:id]) if registered_user

        db.clients.init_crypt(client[:session_id])
        reply build(:crypt_setup)

        if db.codec.recheck(db.clients.most_popular_codec)
          codec = build(:codec_version)

          db.clients.except(client[:session_id]).each do |target|
            post codec, to: target
          end
        end

        reply(codec || build(:codec_version))

        build(:all_channels).each { |state| reply state }
        build(:authorized_clients).each { |state| reply state }

        reply build(:user_state, client: client)
        reply build(:server_sync, client: client)

        client_state = build(:user_state, client: client)
        db.clients.authorized.each { |client| post client_state, to: client }

        reply build(:server_config)
      end
    end
  end
end
