# frozen_string_literal: true

module Persistence
  module Repositories
    class Rooms < Repository
      index :by_id, type: Indexes::Uniq
      index :child_of, type: Indexes::Multi

      def all
        index_by_id.values
      end

      def exists?(id)
        index_by_id.exists?(id)
      end

      def get_parent(child_room)
        index_by_id.get(child_room.parent_id)
      end

      def get_children(parent_room)
        index_child_of.get(parent_room.id)
      end

      def create(name:, id: nil, parent_id: nil, position: nil)
        room = Entities::Room.new

        room.id = id.nil? ? id_pool.obtain : id_pool.reserve(id)
        room.name = name
        room.parent_id = parent_id
        room.position = position
        # room.parent = parent_id.nil? ? nil : index_by_id.get(parent_id)
        room.clients = []

        index_by_id.set(id, room)
        index_child_of.add(room.parent_id, room)

        room
      end

      # def move_client(room_id, client)
      #   current_room = index_client_in_room.get(client.session_id)
      #   if current_room
      #     current_room.clients.delete(client)
      #     index_client_in_room.remove(client.session_id)
      #     index_clients_in_room.remove(current_room.id, client)
      #   end
      #
      #   new_room = index_by_id.get(room_id)
      #   new_room.clients.push(client)
      #
      #   index_listeners.add(room_id, client)
      #   index_clients_in_room.add(client.session_id, new_room)
      #
      #   true
      # end

      # def clients_in_room(room_id)
      #   index_clients_in_room.get(room_id)
      # end
      # # alias :clients_in_room :listeners
      #
      # def clients_in_rooms(room_ids)
      #   index_clients_in_room.get_many(room_ids)
      # end
    end
  end
end
