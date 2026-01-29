# frozen_string_literal: true

require 'concurrent-ruby'

require 'zeitwerk'
require 'optparse'

require 'dry/core/class_attributes'
require 'dry-types'
require 'dry-initializer'

require 'rb_mumble_protocol'

require 'rom'
require 'rom-yaml'

require 'async'
require 'async/io'
# require "io/endpoint"

require 'async/queue'
require 'async/barrier'
require 'async/condition'
require 'async/io/trap'

require 'async/io/protocol/generic'
