#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/app'

Sync do
  App.start!
end
