# frozen_string_literal: true

module Actions
  module Tcp
    module Incoming
      class Authenticate < Dispatch[TcpAction, ::Proto::Mumble::Authenticate]
        class AuthError < ::ConnectionClosingError; end

        def handle
          reject!(:ServerFull) if db.clients.count >= app.config[:max_users]
          reject!(:UsernameInUse) if db.clients.by_name(message.username)

          registered_user = db.users.by_name(message.username)
          if registered_user && registered_user.password != message.password
            reject! :WrongServerPW
          end

          if message.username.empty? || message.username.size > app.config[:max_username_length]
            reject! :InvalidUsername
          end

          app.logger.info "Connecting #{message.username} (#{client.session_id})"

          db.clients.set_auth(client, message)
          db.clients.update(client, user_id: registered_user.id) if registered_user

          reply build(:suggest_config)

          db.clients.init_crypt(client)
          reply build(:crypt_setup)

          # if db.codec.recheck(db.clients.most_popular_codec)
          #   codec = build(:codec_version)
          #
          #   db.clients.except(client.session_id).each do |target|
          #     send_tcp codec, to: target
          #   end
          # end

          # reply(codec || build(:codec_version))

          build(:all_channels).each { |state| reply state }

          db.clients.update(client, room_id: app.config[:default_room])

          client_state = build(:user_state, client: client)

          db.clients.authorized
            .reject { |c| c.session_id == client.session_id }
            .each { |another_client| reply build(:user_state, client: another_client) }
            .each { |another_client| send_tcp client_state, to: another_client }

          reply build(:user_state, client: client)

          reply build(:server_sync, client: client)
          reply build(:server_config)

          app.logger.info "Connected #{message.username} (#{client.session_id})"
        end

        private

        def reject!(reason)
          app.logger.info "Auth rejected #{message.username} (#{client.session_id}): #{reason}"

          reply build(:server_reject, reason: reason)

          # TODO: replace with catch/throw, but exception will do for now
          raise AuthError, reason
        end
      end
    end
  end
end
