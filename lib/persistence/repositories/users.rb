# frozen_string_literal: true

module Persistence
  module Repositories
    class Users < ROM::Repository[:users]
      auto_struct false

      def all
        users.to_a
      end

      def delete(user_id)
        users
          .dataset
          .delete_if { |user| user[:id] == user_id }
      end

      def all_users_state
        users.map { |user| build_state(user) }
      end

      def state_by(user_id)
        build_state(find(user_id))
      end

      def except_by(user_id)
        users.reject { |user| user[:id] == user_id }
      end

      def build_state(user)
        Proto::Mumble::UserState.new(
          session: user[:id],
          name: user[:auth][:username],
          channel_id: 0
        )
      end

      def find(user_id)
        users
          .restrict(id: user_id)
          .one
      end

      def create(queue_in:)
        users
          .command(:create)
          .call(
            id: IdRegistry.instance[:users],
            queue_in: queue_in,
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
