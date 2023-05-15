# frozen_string_literal: true

module Messages
  module Factory
    class UserState < Registry[:user_state]
      def call(input)
        Proto::Mumble::UserState.new(
          session: input[:user][:id],
          name: input[:user][:auth][:username],
          channel_id: 0
        )
      end
    end
  end
end
