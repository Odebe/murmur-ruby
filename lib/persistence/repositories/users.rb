# frozen_string_literal: true

module Persistence
  module Repositories
    class Users < ROM::Repository[:users]
      auto_struct false

      def all
        users.to_a
      end

      def all_users_state
        users.map do |user|
          Proto::Mumble::UserState.new(
            session: user[:id],
            name: user[:auth][:username],
            channel_id: 0
          )
        end
      end

      def find(user_id)
        users
          .restrict(id: user_id)
          .one
      end

      def create
        users
          .command(:create)
          .call(
            id: IdRegistry.instance[:users],
            version: {},
            auth: {}
          )
          .last
      end

      def set_version(user_id, version)
        users
          .restrict(id: user_id)
          .command(:update)
          .call(version: version.to_hash)
      end

      def set_auth(user_id, auth)
        users
          .restrict(id: user_id)
          .command(:update)
          .call(auth: auth.to_hash)
      end
    end
  end
end
