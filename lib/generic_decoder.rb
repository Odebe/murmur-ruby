# frozen_string_literal: true

require 'async/io/protocol/generic'

class GenericDecoder < Async::IO::Protocol::Generic
  def send_message(_msg)
    raise 'interface method'
  end

  def read_message
    raise 'interface method'
  end
end
