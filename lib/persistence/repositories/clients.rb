# frozen_string_literal: true

module Persistence
  module Repositories
    class Clients < Repository
      index :by_id, type: Indexes::Uniq
      index :by_username, type: Indexes::Uniq
      index :by_udp_address, type: Indexes::Uniq
      index :by_remote_address, type: Indexes::Uniq
      index :by_status, type: Indexes::Multi
      index :by_same_ip, type: Indexes::Multi
      index :client_in_room, type: Indexes::Uniq
      index :clients_in_room, type: Indexes::Multi

      index :room_tcp_listeners, type: Indexes::Multi
      index :room_udp_listeners, type: Indexes::Multi

      def count
        index_by_id.size
      end

      def by_id(id)
        index_by_id.get(id)
      end

      def init_crypt(client)
        client.crypt_state = ::Client::CryptoState.new
      end

      def all
        index_by_id.values
      end

      def authorized
        index_by_status.get(:authorized)
      end

      def authorized?(client)
        client.status == :authorized
      end

      def by_name(name)
        index_by_username.get(name)
      end

      def find(session_id)
        index_by_id.get(session_id)
      end

      def by_sessions(session_ids)
        index_by_id.get_many(session_ids)
      end

      def tcp_listeners(room_id)
        index_room_tcp_listeners.get(room_id)
      end

      def udp_listeners(room_id)
        index_room_udp_listeners.get(room_id)
      end

      def set_tcp_listener(client)
        index_room_udp_listeners.remove(client.room_id, client)
        index_room_tcp_listeners.add(client.room_id, client)
      end

      def set_udp_listener(client)
        index_room_tcp_listeners.remove(client.room_id, client)
        index_room_udp_listeners.add(client.room_id, client)
      end

      def create(queue, app, remote_address)
        client = Entities::Client.new

        client.timers = Timers::Group.new
        client.session_id = id_pool.obtain
        client.status = :initialized
        client.traffic_shaper = ::Client::TrafficShaper.new(app.config.max_bandwidth)
        client.user_id = nil
        client.room_id = 0
        client.username = nil
        client.self_mute = false
        client.self_deaf = false
        client.password = nil
        client.udp_used = false
        client.remote_address = remote_address
        client.tcp_queue = queue
        client.version = {}
        client.tokens = []
        client.celt_versions = []
        client.opus = false # TODO: check later, we only use opus now
        client.client_type = :unknown

        index_by_id.set(client.session_id, client)
        index_by_username.set(client.username, client)
        index_by_remote_address.set(remote_address, client)
        index_by_same_ip.add(remote_address.ip_address, client)
        index_by_status.add(client.status, client)
        index_client_in_room.set(client.session_id, client.room_id)
        index_clients_in_room.add(client.room_id, client)
        index_room_tcp_listeners.add(client.room_id, client)

        client
      end

      def set_room(client, new_room_id)
        current_room = index_client_in_room.get(client.session_id)
        listener_index = client_room_index(client)

        if current_room
          index_client_in_room.remove(client.session_id)
          index_clients_in_room.remove(current_room.id, client)
          listener_index.remove(current_room.room_id, client)
        end

        client.room_id = new_room_id
        index_client_in_room.add(client.session_id, new_room_id)
        index_clients_in_room.add(new_room_id, client)
        listener_index.add(new_room_id, client) unless client.self_deaf

        true
      end

      def set_self_deaf(client, deaf)
        client.self_deaf = deaf
        listener_index = client_room_index(client)

        if deaf
          listener_index.remove(client.room_id, client)
        else
          listener_index.add(client.room_id, client)
        end
      end

      def client_room_index(client)
        client.udp_used ? index_room_udp_listeners : index_room_tcp_listeners
      end

      def update(client, **args)
        args.each do |key, value|
          next if key == :session_id

          client.send("#{key}=", value)
        end
      end

      def by_udp_address(address)
        index_by_udp_address.get(address)
      end

      def by_remote_address(address)
        index_by_remote_address.get(address)
      end

      def by_same_ip(address)
        index_by_same_ip.get(address.ip_address)
      end

      def set_version(client, version)
        client.version = version.to_hash
      end

      def set_auth(client, auth)
        index_by_status.remove(client.status, client)
        index_by_username.remove(client.username)

        client.username = auth.username
        client.password = auth.password
        client.tokens = auth.tokens
        client.celt_versions = auth.celt_versions
        client.opus = auth.opus
        client.client_type = auth.client_type
        client.status = :authorized

        index_by_status.add(client.status, client)
        index_by_username.set(client.username, client)
      end

      def delete(client)
        clean_indexes(client.session_id)
        id_pool.release(client.session_id)
      end
    end
  end
end
