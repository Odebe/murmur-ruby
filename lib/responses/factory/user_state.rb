# frozen_string_literal: true

module Responses
  module Factory
    class UserState < Registry[:user_state]
      def call(input)
        client = input[:client]

        Proto::Mumble::UserState.new(
          session:                  client.session_id,
          actor:                    nil,
          name:                     client.username,
          user_id:                  client.user_id,
          channel_id:               client.room_id,
          mute:                     nil,
          deaf:                     nil,
          suppress:                 nil,
          self_mute:                client.self_mute,
          self_deaf:                client.self_deaf,
          texture:                  nil,
          plugin_context:           nil,
          plugin_identity:          nil,
          comment:                  nil,
          hash:                     nil,
          comment_hash:             nil,
          texture_hash:             nil,
          priority_speaker:         nil,
          recording:                nil,
          temporary_access_tokens:  [],
          listening_channel_add:    [],
          listening_channel_remove: []
        )
      end
    end
  end
end
