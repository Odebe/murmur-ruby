# frozen_string_literal: true

module Messages
  module Factory
    class UserState < Registry[:user_state]
      def call(input)
        Proto::Mumble::UserState.new(
          id:         input[:client][:user_id],
          session:    input[:client][:session_id],
          name:       input[:client][:username],
          channel_id: 0
        )
      end
    end
  end
end
