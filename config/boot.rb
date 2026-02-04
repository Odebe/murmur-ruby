# frozen_string_literal: true

require 'zeitwerk'
require 'optparse'

require 'concurrent-ruby'

require 'dry/core/class_attributes'
require 'dry-types'
require 'dry-initializer'

require 'rb_mumble_protocol'

require 'rom'
require 'rom-yaml'

require 'logger'
require 'ostruct'

require 'async'
require 'async/queue'
require 'async/barrier'
require 'async/condition'
require 'async/io/trap'

# TODO: remove
require 'async/io/protocol/generic'

require "io/endpoint"
require "io/endpoint/ssl_endpoint"

require "io/stream"
