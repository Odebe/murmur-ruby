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
          max_bandwidth: settings[:max_bandwidth],
          welcome_text: settings[:welcome_text],
          permissions: 1
        )
      )

      current_state = users.state_by(@user_id)
      users.except_by(@user_id).each do |user|
        user[:queue_in] << current_state
      end
    end
  end
end
