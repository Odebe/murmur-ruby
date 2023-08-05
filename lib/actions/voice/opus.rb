# frozen_string_literal: true

module Actions
  module Voice
    class Opus < Dispatch[Implementation, ::Voice::Packet::Opus]
    end
  end
end
