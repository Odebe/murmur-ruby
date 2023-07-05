# frozen_string_literal: true

class App
  extend Dry::Initializer

  option :config
  option :db
  option :logger, default: -> { AsyncLogger.new }

  def setup!
    db.setup!
  end

  def start!
    logger.start!
  end
end
