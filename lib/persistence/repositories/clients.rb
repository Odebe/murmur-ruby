
# frozen_string_literal: true

module Persistence
  module Repositories
    class Clients < Repository[:clients]
      # struct_namespace Entities
      auto_struct false

      def all
        clients.to_a
      end

      def find(session_id)
        clients.restrict(session_id: session_id)
      end

      def create(stream, queue)
        clients
          .command(:create)
          .call(
            session_id: id_pool.obtain,
            user_id: nil,
            username: nil,
            password: nil,
            queue: queue,
            stream: stream,
            version: {},
            tokens: [],
            celt_versions: [],
            opus: nil,
            client_type: nil
          )
          .last
      end

      def set_version(session_id, version)
        clients
          .restrict(session_id: session_id)
          .command(:update)
          .call(version: version.to_hash)
      end

      def set_auth(session_id, auth)
        clients
          .restrict(session_id: session_id)
          .command(:update)
          .call(auth.to_hash)
      end

      def delete(session_id)
        clients
          .dataset
          .delete_if { |user| user[:session_id] == session_id }
      end
    end
  end
end
