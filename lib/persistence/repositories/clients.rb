
# frozen_string_literal: true

module Persistence
  module Repositories
    class Clients < Repository[:clients]
      auto_struct false

      def count
        all.count
      end

      def init_crypt(session_id)
        clients
          .restrict(session_id: session_id)
          .command(:update)
          .call(crypt_key: Cipher::Key.new)
      end

      def except(session_id)
        all.reject { |c| c[:session_id] == session_id }
      end

      def most_popular_codec
        codec_popularity.max_by { |_k, v| v }&.first
      end

      def codec_popularity
        clients.flat_map { |c| c[:celt_versions] }.tally
      end

      def all
        clients.to_a
      end

      def authorized
        clients.restrict(state: :authorized)
      end

      def by_name(name)
        clients.restrict(username: name).to_a.last
      end

      def find(session_id)
        clients.restrict(session_id: session_id)
      end

      def create(stream, queue)
        clients
          .command(:create)
          .call(
            session_id: id_pool.obtain,
            state: :initialized,
            user_id: nil,
            room_id: 0,
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

      def update(session_id, **args)
        clients
          .restrict(session_id: session_id)
          .command(:update)
          .call(args)
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
          .then { |deleted| id_pool.release(session_id) if deleted }
      end
    end
  end
end
