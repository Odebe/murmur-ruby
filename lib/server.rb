# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

class Server
  attr_reader :endpoint, :rom

  def initialize(endpoint, rom)
    @endpoint = endpoint
    @rom      = rom
  end

  def start!
    endpoint.accept do |socket|
      socket = Async::IO::Stream.new(socket)
      stream = Proto::Stream.new(socket)

      Client::Handler.new(stream, rom).start!
    end
  end
end
