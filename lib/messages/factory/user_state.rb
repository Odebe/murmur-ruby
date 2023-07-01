# frozen_string_literal: true

module Messages
  module Factory
    class UserState < Registry[:user_state]
      def call(input)
        Proto::Mumble::UserState.new(
          id:         input[:client][:user_id],
          session:    input[:client][:session_id],
          name:       input[:client][:username],
          channel_id: input[:client][:room_id]
        )
      end
    end
  end
end
