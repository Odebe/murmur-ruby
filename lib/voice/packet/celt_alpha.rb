# frozen_string_literal: true

module Voice
  class Packet
    class CeltAlpha < Voice
      include SegmentedPayload
    end
  end
end
