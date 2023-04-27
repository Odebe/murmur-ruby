# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

class Server
  include MessageHandlers

  attr_reader :endpoint

  def initialize(endpoint)
    @endpoint = endpoint
  end

  def start!
    Async do
      endpoint.accept do |socket|
        stream = Async::IO::Stream.new(socket)
        client = Client.new(stream)

        connected(client)
      end
    end
  end

  private

  def connected(client)
    client_loop(client)
  end

  def client_loop(client)
    loop do
      message = client.message
      break if message.nil?

      Async { handle message }
    end
  rescue EOFError
    # It's okay, client has disconnected.
  end

  def handle_not_defined(message)
    puts "Undefined message: #{message.inspect}"
  end
end
