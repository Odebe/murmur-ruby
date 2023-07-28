# frozen_string_literal: true

module Actions
  class UdpAction < Base
    def reply(message)
      target = client.blank? ? message.sender : client[:udp_address]

      app.udp_handler.queue << message.with_target(target)
    end
  end
end
