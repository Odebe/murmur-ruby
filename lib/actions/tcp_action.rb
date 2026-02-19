# frozen_string_literal: true

module Actions
  class TcpAction < Base
    def build(name, input = {})
      Responses::Registry
        .call(name)
        .new(client, app)
        .call(input)
    end

    def reply(message)
      client.tcp_queue << message
    end

    private

    def udp?
      false
    end

    def tcp?
      true
    end
  end
end
