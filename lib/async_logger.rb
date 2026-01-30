# frozen_string_literal: true

require 'logger'

class AsyncLogger
  extend Dry::Initializer

  option :logger, default: -> { Logger.new($stdout) }
  option :queue,  default: -> { Async::Queue.new }

  def start!
    loop do
      level, msg = queue.dequeue
      logger.public_send(level, msg)

      Async::Task.current.yield
    end
  end

  %i[
    info
    error
    debug
  ].each do |level|
    define_method level do |msg|
      queue << [level, msg]
    end
  end
end
