# frozen_string_literal: true

module Actions
  class TcpAction < Base
    def build(name, input = {})
      Messages::Registry
        .call(name)
        .new(client, app)
        .call(input)
    end
  end
end
