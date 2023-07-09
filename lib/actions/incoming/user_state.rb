# frozen_string_literal: true

module Actions
  module Incoming
    class UserState < Dispatch[::Proto::Mumble::UserState]
      attr_reader :announce, :target

      def handle
        authorize!

        check_permission!
        find_target!

        build_announce

        check_self_mute
        check_self_deaf
        check_channel_change

        broadcast_announce
      end

      private

      # Only allow state changes for for the self user
      # TODO: allow for admins
      def check_permission!
        # client may send 0 as "my state before sync"
        return if message.session >= 0
        return if message.session == client[:session_id]

        reply build(:permission_denied, reason: 'Permission denied')
        halt!
      end

      def find_target!
        if message.session.zero?
          @target = client
        else
          @target = db.clients.find(message.session)
          return if @target

          halt!
        end
      end

      def build_announce
        @announce = ::Proto::Mumble::UserState.new(session: target[:session_id])
      end

      def broadcast_announce
        db.clients.authorized.each { |another_client| post announce, to: another_client }
      end

      def check_channel_change
        return if message.channel_id.nil?
        return unless message.channel_id != client[:channel_id]
        return unless db.rooms.exists?(message.channel_id)

        db.clients.update(client[:session_id], room_id: message.channel_id)
        announce.channel_id = message.channel_id
      end

      def check_self_mute
        return if message.self_mute.nil?

        db.clients.update(client[:session_id], self_deaf: message.self_mute)
        announce.self_mute = message.self_mute
        return unless message.self_mute

        db.clients.update(client[:session_id], self_deaf: false)
        announce.self_mute = false
      end

      def check_self_deaf
        return if message.self_deaf.nil?

        db.clients.update(client[:session_id], self_deaf: message.self_deaf)
        announce.self_deaf = message.self_deaf
        return unless client[:self_deaf]

        db.clients.update(client[:session_id], self_mute: true)
        announce.self_mute = true
      end
    end
  end
end
