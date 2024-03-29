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
          .call(crypt_state: ::Client::CryptoState.new)
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
        clients.restrict(status: :authorized)
      end

      def authorized?(session_id)
        authorized.restrict(session_id: session_id).any?
      end

      def by_name(name)
        clients.restrict(username: name).to_a.last
      end

      def find(session_id)
        clients.restrict(session_id: session_id).to_a.last
      end

      def by_sessions(session_ids)
        clients.restrict(session_id: session_ids).to_a
      end

      def in_rooms(room_ids, except: [])
        clients
          .restrict(room_id: room_ids)
          .reject { |c| except.include?(c[:session_id]) }
      end

      def listeners(room_id, except: [])
        clients
          .restrict(room_id: room_id, self_deaf: false)
          .reject { |c| except.include?(c[:session_id]) }
      end

      def create(queue, app)
        clients
          .command(:create)
          .call(
            timers:         Timers::Group.new,
            session_id:     id_pool.obtain,
            status:         :initialized,
            traffic_shaper: ::Client::TrafficShaper.new(app.config.max_bandwidth),
            user_id:        nil,
            room_id:        0,
            username:       nil,
            self_mute:      false,
            self_deaf:      false,
            password:       nil,
            tcp_queue:      queue,
            version:        {},
            tokens:         [],
            celt_versions:  [],
            opus:           nil,
            client_type:    nil
          )
          .last
      end

      def update(session_id, **args)
        clients
          .restrict(session_id: session_id)
          .command(:update)
          .call(args)
      end

      def by_udp_address(address)
        clients
          .restrict(udp_address: address)
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
          .call(auth.to_hash.merge(status: :authorized))
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
