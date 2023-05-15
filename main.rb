# frozen_string_literal: true

module App
  def self.root_path
    Pathname(__dir__)
  end

  def self.lib_path
    root_path.join('lib')
  end

  def self.persistence_path
    lib_path.join('persistence')
  end

  # TODO: read from outside
  def self.settings
    {
      host: '127.0.0.1',
      port: 64_738,
      max_bandwidth: 72_000,
      welcome_text: 'Hello world!',
      ssl: {
        cert: 'server.cert',
        key: 'server.key'
      }
    }
  end
end

require 'byebug'

require 'concurrent-ruby'

require 'dry/core/class_attributes'
require 'dry-types'
require 'rom'
require 'rom-repository'

require 'async/queue'
require 'async/waiter'
require 'async/io'

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir(App.lib_path)
loader.setup

server = Server.new(App.settings)
server.setup_persistence!
server.setup_endpoint!

loader.eager_load

Async { server.start_tcp! }
