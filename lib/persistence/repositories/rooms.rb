# frozen_string_literal: true

module Persistence
  module Repositories
    class Rooms < Repository[:rooms]
      # struct_namespace Entities
      auto_struct false

      def all
        rooms.to_a
      end

      def exists?(id)
        rooms.restrict(id: id).any?
      end

      def create_root
        create_room(name: 'Root')
      end

      def create_room(name:)
        IdRegistry.instance[:rooms] do |id|
          rooms
            .command(:create)
            .call(id: id, name: name)
        end
      end

      def all_channels_state
        rooms.map do |room|
          Proto::Mumble::ChannelState.new(
            channel_id: room[:id],
            parent:     nil,
            name:       room[:name]
          )
        end
      end
    end
  end
end
