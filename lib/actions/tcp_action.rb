# frozen_string_literal: true

module Actions
  class TcpAction < Base
    def authorize!
      halt! unless db.clients.authorized?(client[:session_id])
    end

    def build(name, input = {})
      Messages::Registry
        .call(name)
        .new(client, app)
        .call(input)
    end

    def reply(message)
      client[:queue] << message
    end

    def post(message, to:)
      to[:queue] << message
    end
  end
end
