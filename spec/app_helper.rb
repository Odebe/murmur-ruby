# frozen_string_literal: true

require 'zeitwerk'
require 'byebug'

require 'concurrent-ruby'

require 'dry/core/class_attributes'
require 'dry-types'
require 'dry-initializer'

require 'rom'
require 'rom-yaml'

require 'async'
require 'async/io'

require 'async/queue'
require 'async/barrier'
require 'async/condition'

loader = Zeitwerk::Loader.new
loader.push_dir(Pathname(__dir__).join('../lib'))
loader.setup
loader.eager_load
