# frozen_string_literal: true

module Voice
  class Packet
    class Speex < Voice
      include SegmentedPayload
    end
  end
end
