# frozen_string_literal: true

module Messages
  module Factory
    class UserState < Registry[:user_state]
      def call(input)
        Proto::Mumble::UserState.new(
          session:                  input[:client][:session_id],
          actor:                    nil,
          name:                     input[:client][:username],
          user_id:                  input[:client][:user_id],
          channel_id:               input[:client][:room_id],
          mute:                     nil,
          deaf:                     nil,
          suppress:                 nil,
          self_mute:                input[:client][:self_mute],
          self_deaf:                input[:client][:self_deaf],
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
