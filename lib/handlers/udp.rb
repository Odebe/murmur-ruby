# frozen_string_literal: true

require 'byebug'

module Handlers
  # Handler per server
  class Udp
    extend Dry::Initializer

    param :io
    param :app

    option :queue,    default: -> { Async::Queue.new }
    option :finished, default: -> { Async::Condition.new }

    option :barrier,    reader: :private, default: -> { Async::Barrier.new }
    option :dispatcher, reader: :private, default: -> { Actions::Dispatch }

    option :decoder, reader: :private, default: -> { Voice::Decoder.new(io) }

    def setup!
      app.udp_handler = self
    end

    def start!
      start_async_tasks!

      finished.wait
    ensure
      shutdown
    end

    private

    def start_async_tasks!
      barrier.async { from_client_loop }
      barrier.async { to_client_loop }
    end

    # TODO: graceful shutdown
    def shutdown
      barrier.stop
    end

    def from_client_loop
      current_task.annotate 'UDP receiving loop'
      current_task.yield

      within_connection do
        loop do
          message = decoder.read_encrypted

          if message.is_a? ::Udp::Encrypted
            decrypted, client = find_client_by_decryption(message.raw)
            next unless client

            sender  = message.sender
            message = ::Voice::Decoder.read_decrypted(decrypted)
            message.sender = sender
          end

          action = dispatcher.call(message)
          action ? action.new(self, message, client, app).call : handle_not_defined(message)

          current_task.yield
        end
      end
    end

    def to_client_loop
      current_task.annotate 'UDP sending loop'
      current_task.yield

      within_connection do
        loop { decoder.send_message(queue.dequeue) }
      end
    end

    def find_client_by_decryption(encrypted)
      app.db.clients.all.each do |client|
        crypt_state = client[:crypt_state]
        next unless crypt_state

        success, value = crypt_state.decrypt(encrypted.bytes)
        next unless success

        return [value.pack('C*'), client]
      end

      [nil, nil]
    end

    def within_connection
      yield
    rescue OpenSSL::SSL::SSLError
      # It's okay, client has disconnected.
    rescue StandardError => e
      app.logger.error(e)
    ensure
      finished.signal(:disconnect)
    end

    def handle_not_defined(message)
      puts "Undefined message: #{message.inspect}"
    end

    def current_task
      Async::Task.current
    end
  end
end
