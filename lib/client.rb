# frozen_string_literal: true

class Client
  def initialize(stream)
    @stream = Proto::Stream.new(stream)
  end

  def message
    @stream.read_message
  end
end
