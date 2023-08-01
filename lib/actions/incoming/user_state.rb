# frozen_string_literal: true

module Actions
  module Incoming
    class UserState < Dispatch[TcpAction, ::Proto::Mumble::UserState]
      attr_reader :announce, :target

      def handle
        authorize!

        check_permission!
        find_target!

        build_announce
        clear_unsupported_fields

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
        @announce = message.clone

        @announce.session = target[:session_id]
        @announce.actor   = client[:session_id]
      end

      def clear_unsupported_fields
        announce.temporary_access_tokens  = []
        announce.listening_channel_add    = []
        announce.listening_channel_remove = []

        # ignoring (self-)registration
        announce.user_id = nil
      end

      def broadcast_announce
        db.clients.authorized.each { |another_client| post announce, to: another_client }
      end

      def check_channel_change
        return unless message.field?(:channel_id)
        return unless db.rooms.exists?(message.channel_id)

        db.clients.update(client[:session_id], room_id: message.channel_id)
        announce.channel_id = message.channel_id
      end

      def check_self_mute
        return unless message.field?(:self_mute)

        db.clients.update(client[:session_id], self_deaf: message.self_mute)
        announce.self_mute = message.self_mute
        return if message.self_mute

        db.clients.update(client[:session_id], self_deaf: false)
        announce.self_deaf = false
      end

      def check_self_deaf
        return unless message.field?(:self_deaf)

        db.clients.update(client[:session_id], self_deaf: message.self_deaf)
        announce.self_deaf = message.self_deaf
        return unless message.self_deaf

        db.clients.update(client[:session_id], self_mute: true)
        announce.self_mute = true
      end
    end
  end
end
