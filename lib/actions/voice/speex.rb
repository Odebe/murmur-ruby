# frozen_string_literal: true

module Actions
  module Voice
    class Speex < Dispatch[Implementation, ::Voice::Packet::Speex]
    end
  end
end
