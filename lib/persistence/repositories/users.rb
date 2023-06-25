# frozen_string_literal: true

module Persistence
  module Repositories
    class Users < Repository[:users]
      struct_namespace Entities

      def all
        users.to_a
      end

      def delete(session_id)
        users
          .dataset
          .delete_if { |user| user[:session_id] == session_id }
      end

      def except_by(session_id)
        users
          .reject { |user| user[:session_id] == session_id }
      end

      def find(session_id)
        users
          .restrict(session_id: session_id)
          .one
      end

      def create(queue_in:)
        IdRegistry.instance[:session_id] do |session|
          users
            .command(:create)
            .call(
              id: -1,
              session_id: session,
              queue_in: queue_in,
              version: {},
              auth: {}
            )
            .last
        end
      end

      def set_version(session_id, version)
        users
          .restrict(session_id: session_id)
          .command(:update)
          .call(version: version.to_hash)
      end

      def set_auth(session_id, auth)
        users
          .restrict(session_id: session_id)
          .command(:update)
          .call(auth: auth.to_hash)
      end
    end
  end
end
