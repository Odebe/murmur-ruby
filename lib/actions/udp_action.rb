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
      # TODO: make it use wrapper message for target addr
      reply_queue << [sender_addr, message]
    end

    private

    def sender_addr
      @wrapped_message.sender_addr
    end

    ############################################################

    def reply_queue
      udp? ? app.udp_handler.queue : client[:tcp_queue]
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

    ############################################################

    # TODO: make consistent with tcp_action.rb
    def send_tcp(message, to:)
      to[:tcp_queue] << message
    end

    def send_udp(message, to:)
      app.udp_handler.queue << [to[:udp_address], message]
    end
  end
end
