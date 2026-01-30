# frozen_string_literal: true

module Actions
  module Tcp
    module Incoming
      class Version < Dispatch[TcpAction, ::Proto::Mumble::Version]
        def handle
          app.db.clients.set_version(client[:session_id], message)

          message.version_v2 = ::Version::SUPPORTED_PROTOCOL_VERSION_V2
          message.version_v1 = ::Version::SUPPORTED_PROTOCOL_VERSION_V1

          reply message
        end
      end
    end
  end
end
