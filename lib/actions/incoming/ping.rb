# frozen_string_literal: true

module Actions
  module Incoming
    class Ping < Dispatch[TcpAction, ::Proto::Mumble::Ping]
      def handle
        crypt = client[:crypt_state]

        if crypt
          stats = crypt.stats

          message.good = stats['good']
          message.late = stats['late']
          message.lost = stats['lost']
        end

        reply message
      end
    end
  end
end
