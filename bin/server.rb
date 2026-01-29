#!/usr/bin/env ruby
require_relative '../config/app'

Sync do
  App.start!
end
