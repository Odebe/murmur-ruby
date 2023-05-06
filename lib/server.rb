# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

class Server
  attr_reader :endpoint, :rom, :settings

  def initialize(endpoint, rom, settings)
    @endpoint = endpoint
    @rom      = rom
    @settings = settings
  end

  def start!
    endpoint.accept do |socket|
      socket = Async::IO::Stream.new(socket)
      stream = Proto::Stream.new(socket)

      Client::Handler.new(stream, rom, settings).start!
    end
  end
end
