# frozen_string_literal: true

module Actions
  class UdpAction < Base
    def initialize(handler, app, wrapped_message)
      @handler = handler
      @message = wrapped_message.message
      @wrapped_message = wrapped_message
      @app     = app
    end

    def reply(message)
      app.udp_handler.queue << [sender_addr, message]
    end

    private

    def sender_addr
      @wrapped_message.sender_addr
    end

    def client
      @wrapped_message.client
    end

    ############################################################

    def udp?
      @wrapped_message.udp?
    end

    # Audio packet can be sent via UDPTunnel so checking message origin
    def tcp?
      @wrapped_message.tcp?
    end
  end
end
