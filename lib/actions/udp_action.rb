# frozen_string_literal: true

module Actions
  class UdpAction < Base
    def reply(message)
      target = client.nil? ? sender_sockaddr : client[:udp_address]

      app.udp_handler.queue << [target, message]
    end
  end
end
