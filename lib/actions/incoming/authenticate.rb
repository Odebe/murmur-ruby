# frozen_string_literal: true

module Actions
  module Incoming
    class Authenticate < Dispatch[::Proto::Mumble::Authenticate]
      def handle(message)
        users.set_auth(user_id, message)

        build(:all_channels).each { |state| reply state }
        build(:all_users).each { |state| reply state }

        reply build(:server_sync, user_id: user_id)

        current_user = users.find(user_id)
        user_state = build(:user_state, user: current_user)

        users.all.reject { |u| u == current_user }.each do |user|
          post user_state, to: user
        end
      end
    end
  end
end
