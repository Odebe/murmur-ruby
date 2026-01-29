# frozen_string_literal: true

module Actions
  module Tcp
    class Disconnect < Base
      def handle
        session_id = client[:session_id]
        message    = ::Proto::Mumble::UserRemove.new(session: session_id)

        app.db.clients.delete(session_id)
        app.db.clients.all.each do |another_client|
          another_client[:tcp_queue] << message
        end
      end
    end
  end
end
