# frozen_string_literal: true

module Messages
  module Factory
    class CodecVersion < Registry[:codec_version]
      def call(_input)
        Proto::Mumble::CodecVersion.new(app.db.codec.to_hash)
      end
    end
  end
end
