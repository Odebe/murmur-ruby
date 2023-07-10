# frozen_string_literal: true

RSpec.describe Client::VoiceStream do
  subject(:stream) { described_class.new(io) }

  describe 'reading' do
    let(:io) { StringIO.new(string).binmode }

    describe '#read_byte' do
      subject(:result) { stream.read_byte }

      let(:string) { "\x01" }

      it { is_expected.to eq(1) }
    end

    describe '#read' do
      subject(:result) { stream.read(2) }

      let(:string) { "\x01\xFE" }

      it { is_expected.to eq([1, 254]) }
    end

    describe '#read_varint' do
      subject(:result) { stream.read_varint }

      context 'when 7-bit positive number' do
        let(:string) { "\x7F" }

        it { is_expected.to eq(0x7F) }
      end

      context 'when 14-bit positive number' do
        let(:string) { "\xBF\x7F" }
        let(:value) { ((0xBF & 0x3F) << 8) | 0x7F }

        it { is_expected.to eq(value) }
      end

      context 'when 21-bit positive number' do
        let(:string) { "\xDF\x7F\x6F" }
        let(:value) { ((0xDF & 0x1F) << 16) | (0x7F << 8) | 0x6F }

        it { is_expected.to eq(value) }
      end

      context 'when 28-bit positive number' do
        let(:string) { "\xEF\xDF\x7F\x6F" }
        let(:value) { ((0xEF & 0x0F) << 24) | (0xDF << 16) | (0x7F << 8) | 0x6F }

        it { is_expected.to eq(value) }
      end

      context 'when 32-bit positive number' do
        let(:string) { "\xF0\xEF\xDF\x7F\x6F" }
        let(:value) { (0xEF << 24) | (0xDF << 16) | (0x7F << 8) | 0x6F }

        it { is_expected.to eq(value) }
      end

      context 'when 64-bit number' do
        let(:string) { "\xF4\xEF\xDF\x7F\x6F\xEF\xDF\x7F\x6F" }
        let(:value) do
          string
            .bytes[1..]
            .reverse_each
            .with_index
            .reduce do |(acc, _), (e, i)|
              acc | (e << (i * 8))
            end
        end

        it { is_expected.to eq(value) }
      end

      context 'when Byte-inverted negative two bit number' do
        let(:string) { "\xFE" }
        let(:value) { ~(0xFE & 0x03) }

        it { is_expected.to eq(value) }
      end

      context 'when Negative recursive varint' do
        let(:string) { "\xF8\xBF\x7F" }
        let(:value) { ~(((0xBF & 0x3F) << 8) | 0x7F) }

        it { is_expected.to eq(value) }
      end
    end
  end

  describe 'writing' do
    subject(:result) { io.string.bytes }

    let(:io) { StringIO.new.binmode }

    describe '#write' do
      before { stream.write(value) }

      context 'when string' do
        let(:value) { "\xF8\xBF" }

        it { is_expected.to eq([0xF8, 0xBF]) }
      end

      context 'when bytes' do
        let(:value) { 0x0A }

        it { is_expected.to eq([0x0A]) }
      end
    end

    describe '#write_varint' do
      before { stream.write_varint(value) }

      context 'when when 7-bit positive number' do
        let(:value) { 0x0A }

        it { is_expected.to eq([0x0A]) }
      end

      context 'when 14-bit positive number' do
        let(:value) { 0x2C78 }
        let(:expected) do
          [
            (value >> 8) | 0x80,
            value & 0xFF
          ]
        end

        it { is_expected.to eq(expected) }
      end

      context 'when 21-bit positive number' do
        let(:value) { 0x200000 - 5000 }
        let(:expected) do
          [
            (value >> 16) | 0xC0,
            (value >> 8) & 0xFF,
            value & 0xFF
          ]
        end

        it { is_expected.to eq(expected) }
      end

      context 'when 28-bit positive number' do
        let(:value) { 0x10000000 - 5000 }
        let(:expected) do
          [
            (value >> 24) | 0xE0,
            (value >> 16) & 0xFF,
            (value >> 8) & 0xFF,
            value & 0xFF
          ]
        end

        it { is_expected.to eq(expected) }
      end

      context 'when 32-bit positive number' do
        let(:value) { 0x100000000 - 5000 }
        let(:expected) do
          [
            0xF0,
            (value >> 24) & 0xFF,
            (value >> 16) & 0xFF,
            (value >> 8) & 0xFF,
            value & 0xFF
          ]
        end

        it { is_expected.to eq(expected) }
      end

      context 'when 64-bit number' do
        let(:value) { 0x100000000 + 5000 }
        let(:expected) do
          [
            0xF4,
            (value >> 56) & 0xFF,
            (value >> 48) & 0xFF,
            (value >> 40) & 0xFF,
            (value >> 32) & 0xFF,
            (value >> 24) & 0xFF,
            (value >> 16) & 0xFF,
            (value >> 8) & 0xFF,
            value & 0xFF
          ]
        end

        it { is_expected.to eq(expected) }
      end

      context 'when Negative recursive varint' do
        let(:value) { -65_536 }
        let(:expected) do
          [
            0xF8,
            (~value >> 16) | 0xC0,
            (~value >> 8) & 0xFF,
            ~value & 0xFF
          ]
        end

        it { is_expected.to eq(expected) }
      end

      context 'when Byte-inverted negative two bit number' do
        let(:value) { -2 }
        let(:expected) { [0xFC | ~value] }

        it { is_expected.to eq(expected) }
      end
    end
  end
end
