# frozen_string_literal: true

RSpec.describe Client::VoiceTrafficShaper do
  subject(:shaper) { described_class.new(bandwidth) }

  let(:bytes_per_second) { 5 }
  let(:bandwidth) { bytes_per_second * 8 }
  let(:byte) { 1 }

  describe '#check!' do
    context 'when packet size greater than bandwidth' do
      it 'drops packet' do
        expect(shaper.check!(bytes_per_second + byte)).to be_falsey
      end
    end

    context 'when packet size smaller than bandwidth' do
      it 'drops packet' do
        expect(shaper.check!(bytes_per_second - byte)).to be_truthy
      end
    end

    context 'when bytes sent greater than bandwidth' do
      it 'drops packet' do
        shaper.check!(bytes_per_second)
        expect(shaper.check!(byte)).to be_falsey
      end
    end

    context 'when bytes sent smaller than bandwidth' do
      it 'drops packet' do
        shaper.check!(bytes_per_second / 2)
        expect(shaper.check!(byte)).to be_truthy
      end
    end
  end

  describe '#reset!' do
    it 'resets bytes_sent counter' do
      shaper.check!(bytes_per_second)
      shaper.reset!
      expect(shaper.check!(bytes_per_second)).to be_truthy
    end
  end
end
