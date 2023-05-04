# frozen_string_literal: true

module MessageHandlers
  module Authentication
    # @param [::Proto::Mumble::Authentication] message
    def handle_authenticate(message)
      users.set_auth(@user_id, message)

      rooms.all_channels_state.each do |state|
        @stream.send_message(state)
      end

      users.all_users_state.each do |state|
        @stream.send_message(state)
      end

      @stream.send_message(
        Proto::Mumble::ServerSync.new(
          session: @user_id,
          max_bandwidth: 72_000,
          welcome_text: 'Hello world!',
          permissions: 1
        )
      )
    end
  end
end
