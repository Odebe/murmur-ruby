# frozen_string_literal: true

module Messages
  module Factory
    class AllUsers < Registry[:all_users]
      def call(_input)
        users.all.map do |user|
          Proto::Mumble::UserState.new(
            session: user[:id],
            name: user[:auth][:username],
            channel_id: 0
          )
        end
      end
    end
  end
end
