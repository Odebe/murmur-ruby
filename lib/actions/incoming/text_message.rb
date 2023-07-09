# frozen_string_literal: true

module Actions
  module Incoming
    class TextMessage < Dispatch[::Proto::Mumble::TextMessage]
      def handle
        authorize!

        targets = []

        if message.tree_id.any?
          reply build(:permission_denied, reason: 'Tree message not supported')
          halt!
        end

        if message.channel_id.any?
          clients = db.clients.in_rooms(message.channel_id, except: [client[:session_id]])
          clients.each { |c| targets << c }
        end

        if message.session.any?
          clients = db.clients.by_sessions(message.session)
          clients.each { |c| targets << c }
        end

        targets.uniq!

        return if targets.none?

        message.actor = client[:session_id]
        targets.each { |t| post message, to: t }
      end
    end
  end
end
