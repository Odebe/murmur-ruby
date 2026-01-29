# frozen_string_literal: true

module Decoders
  class Generic < Async::IO::Protocol::Generic
    def send_message(_msg)
      raise 'interface method'
    end

    def read_message
      raise 'interface method'
    end
  end
end
