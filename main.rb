# frozen_string_literal: true

require 'concurrent-ruby'

require 'dry/core/class_attributes'
require 'dry-types'
require 'dry-initializer'

require 'rb_mumble_protocol'

require 'rom'
require 'rom-yaml'

require 'async'
require 'async/io'

require 'async/queue'
require 'async/barrier'
require 'async/condition'
require 'async/io/trap'

require_relative 'lib/configurator'

app = Configurator.call

require 'async/debug' if app.config.debug_web

Sync do
  Async::Debug.serve if app.config.debug_web

  app.start!

  exit
end
