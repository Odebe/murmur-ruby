# frozen_string_literal: true

module Actions
  class UdpAction < Base
    def reply(message)
      handler.queue << message.with_target(message.sender)
    end

    def post(message, to:)
      # TODO
    end
  end
end
