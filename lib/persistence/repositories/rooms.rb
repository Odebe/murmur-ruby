# frozen_string_literal: true

module Persistence
  module Repositories
    class Rooms < ROM::Repository[:rooms]
      auto_struct false

      def create_root
        create_room(name: 'Root')
      end

      def create_room(name:)
        rooms
          .command(:create)
          .call(id: IdRegistry.instance[:rooms], name: name)
      end

      def all_channels_state
        rooms.map do |room|
          Proto::Mumble::ChannelState.new(
            channel_id: room[:id],
            parent: nil,
            name: room[:name]
          )
        end
      end
    end
  end
end
