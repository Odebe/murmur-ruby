# frozen_string_literal: true

module Messages
  module Factory
    class AllChannels < Registry[:all_channels]
      def call(_input)
        app.db.rooms.all.map do |room|
          Proto::Mumble::ChannelState.new(
            channel_id: room[:id],
            parent: room[:parent_id],
            name: room[:name],
          )
        end
      end
    end
  end
end
