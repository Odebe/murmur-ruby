# frozen_string_literal: true

module Messages
  module Factory
    class AllClients < Registry[:all_clients]
      def call(_input)
        app.db.clients.all.map do |client|
          Proto::Mumble::UserState.new(
            id:         client[:user_id],
            session:    client[:session_id],
            name:       client[:username],
            channel_id: 0
          )
        end
      end
    end
  end
end
