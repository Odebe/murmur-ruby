# frozen_string_literal: true

require 'zeitwerk'

class App
  module Path
    def root_path
      Pathname(__dir__).join('..')
    end

    def lib_path
      root_path.join('lib')
    end

    def run_path
      root_path.join('run')
    end

    def persistence_path
      lib_path.join('persistence')
    end
  end

  # TODO: read from outside
  module Configuration
    def settings
      {
        host: '127.0.0.1',
        port: 64_738,
        ssl: {
          cert: 'server.cert',
          key: 'server.key'
        },
        db: {
          path: run_path.join('db.yml')
        }
      }
    end

    def config
      {
        max_bandwidth: 48_000 / 8,
        welcome_text: 'Hello world!',
        allow_html: false,
        message_length: 500,
        image_message_length: 0,
        max_users: 15,
        recording_allowed: true,
        max_username_length: 20
      }
    end
  end

  include Path
  include Configuration

  extend Dry::Initializer

  option :db,     default: -> { false }
  option :loader, default: -> { Zeitwerk::Loader.new }

  def setup!
    loader.push_dir(lib_path)
    loader.setup

    setup_persistence!

    loader.eager_load
  end

  def setup_persistence!
    @db ||= Persistence::Db.new(self)
    @db.setup!
  end
end
