# frozen_string_literal: true

module Actions
  module Tcp
    module Incoming
      class Version < Dispatch[TcpAction, ::Proto::Mumble::Version]
        MUMBLE_PROTOCOL_VERSION = Gem::Version.new('1.5.0')

        VERSION_V1 = Client::Version.to_v1(MUMBLE_PROTOCOL_VERSION)
        VERSION_V2 = Client::Version.to_v2(MUMBLE_PROTOCOL_VERSION)

        def handle
          app.db.clients.set_version(client[:session_id], message)

          message.version_v2 = VERSION_V2
          message.version_v1 = VERSION_V1

          reply message
        end
      end
    end
  end
end
