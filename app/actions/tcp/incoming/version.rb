# frozen_string_literal: true

module Actions
  module Tcp
    module Incoming
      PROTOBUF_INTRODUCTION_VERSION = "1.5.0"

      class Version < Dispatch[TcpAction, ::Proto::Mumble::Version]
        def handle
          app.db.clients.set_version(client[:session_id], message)

          # TODO: send server version
          reply message
        end
      end
    end
  end
end
