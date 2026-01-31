# frozen_string_literal: true

module Actions
  module Tcp
    module Incoming
      class TextMessage < Dispatch[TcpAction, ::Proto::Mumble::TextMessage]
        attr_reader :targets, :announce

        def handle
          authorize!
          check_permission!

          build_announce

          check_channel
          check_client

          send_announce
        end

        private

        def build_announce
          @targets  = []
          @announce = message
          @announce.actor = client[:session_id]
        end

        def send_announce
          targets.uniq!
          return if targets.none?

          targets.each { |t| send_tcp message, to: t }
        end

        def check_channel
          return if message.channel_id.size == 0

          clients = db.clients.in_rooms(message.channel_id, except: [client[:session_id]])
          targets.push(*clients)
        end

        def check_client
          return if message.session.size == 0

          clients = db.clients.by_sessions(message.session)
          targets.push(*clients)
        end

        def check_permission!
          return if message.tree_id.size == 0

          reply build(:permission_denied, reason: 'Tree message not supported')
          halt!
        end
      end
    end
  end
end
