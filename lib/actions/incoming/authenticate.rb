# frozen_string_literal: true

module Actions
  module Incoming
    class Authenticate < Dispatch[::Proto::Mumble::Authenticate]
      def handle(message)
        users.set_auth(user_id, message)

        rooms.all_channels_state.each { |state| reply state }
        users.all_users_state.each { |state| reply state }

        server_sync =
          Proto::Mumble::ServerSync.new(
            session: user_id,
            max_bandwidth: settings[:max_bandwidth],
            welcome_text: settings[:welcome_text],
            permissions: 1
          )
        reply server_sync

        current_state = users.state_by(user_id)
        users.except_by(user_id).each do |user|
          post current_state, to: user
        end
      end
    end
  end
end
