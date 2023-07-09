# frozen_string_literal: true

module Actions
  module Incoming
    class PermissionQuery < Dispatch[::Proto::Mumble::PermissionQuery]
      def handle
        authorize!

        reply ::Proto::Mumble::PermissionQuery.new(
          channel_id:  message.channel_id,
          permissions: Acl.granted_permissions(client, nil)
        )
      end
    end
  end
end
