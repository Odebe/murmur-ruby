# frozen_string_literal: true

module Actions
  class TcpAction < Base
    def build(name, input = {})
      Messages::Registry
        .call(name)
        .new(client, app)
        .call(input)
    end

    def reply(message)
      client[:tcp_queue] << message
    end
  end
end
