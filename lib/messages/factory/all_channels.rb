# frozen_string_literal: true

module Messages
  module Factory
    class AllChannels < Registry[:all_channels]
      def call(_input)
        rooms.all.map do |room|
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
