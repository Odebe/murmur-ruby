#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/app'

require 'ruby-prof'

$profile = RubyProf::Profile.new

$profile.start
$profile.pause

begin
  Sync do

    App.start!
  end
ensure
  result = $profile.stop
  printer = RubyProf::GraphHtmlPrinter.new(result)
  printer.print(File.open("ruby-proof-3.html", "w"))
end
