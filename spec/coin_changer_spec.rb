# frozen_string_literal: true

require_relative '../coin_changer'

describe CoinChanger do
  subject { described_class.new(total_change, till).process }

  describe '#process' do
    context 'three coins' do
      let(:total_change) { 125 }
      let(:till) { { 25 => 2, 50 => 3 } }

      it 'returns correct change' do
        expect(subject).to eq({ 25 => 1, 50 => 2 })
      end
    end

    context 'big total change amount' do
      let(:total_change) { 475 }
      let(:till) { { 25 => 500, 50 => 5, 100 => 5, 200 => 50, 300 => 0, 500 => 5 } }

      it 'returns correct change' do
        expect(subject).to eq({ 25 => 1, 50 => 1, 200 => 2 })
      end
    end

    context 'insufficient coins' do
      let(:total_change) { 500 }
      let(:till) { { 25 => 2, 50 => 3 } }

      it 'raises insufficient coins error' do
        expect{ subject }.to raise_error(CoinChanger::InsufficientCoins)
      end
    end
  end
end