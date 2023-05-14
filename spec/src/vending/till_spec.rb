# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../src/vending'

describe Vending::Till do
  subject { described_class.new(coins) }
  let(:coins) { { 25 => 5, 50 => 5, 100 => 5, 200 => 5, 300 => 5, 500 => 5 } }

  describe '#valid_coins' do
    it 'returns possible coin denominations' do
      expect(subject.valid_coins).to eq([25, 50, 100, 200, 300, 500])
    end
  end

  describe '#accept_coin' do
    context 'valid input' do
      it 'accepts known coins' do
        expect do
          subject.new_transaction
          subject.accept_coin('100')
        end.to change { subject.coins[100] }.by(1)
      end

      it 'keeps track of total input in a single transaction' do
        subject.new_transaction
        subject.accept_coin('100')
        subject.accept_coin('500')

        expect(subject.transaction_total).to eq 600
      end

      it 'resets total input after a new transaction' do
        subject.new_transaction
        subject.accept_coin('100')
        subject.new_transaction
        subject.accept_coin('100')

        expect(subject.transaction_total).to eq 100
      end
    end

    context 'invalid input' do
      it 'rejects text input' do
        expect(subject.accept_coin('test')).to be false
      end

      it 'rejects text with numbers' do
        expect(subject.accept_coin('1test')).to be false
      end

      it 'rejects unknown denominations' do
        expect(subject.accept_coin('15')).to be false
      end
    end
  end

  describe '#process_change' do
    before do
      allow(Vending::CoinChanger).to receive(:new).and_return(coin_changer_double)
    end
    let(:coin_changer_double) { double(process: coin_changer_response) }
    let(:coin_changer_response) { { 100 => 1 } }

    context 'when change is not needed' do
      before { allow(subject).to receive(:return_change) }

      it 'does not return change' do
        subject.new_transaction
        subject.accept_coin('500')
        subject.process_change(500)

        expect(subject).not_to have_received(:return_change)
      end
    end

    context 'when change can be returned' do
      let(:coin_changer_response) { { 100 => 1 } }

      it 'subtracts the change from the till' do
        subject.new_transaction
        subject.accept_coin('300')
        subject.process_change(200)

        expect(subject.coins[100]).to be 4
      end
    end

    context 'when insufficient coins to return change' do
      before do
        allow(Vending::CoinChanger).to receive_message_chain(
          :new, :process
        ).and_raise(Vending::CoinChanger::InsufficientCoins)
      end

      it "returns user's coins inserted so far" do
        subject.new_transaction
        subject.accept_coin('300')
        subject.process_change(50)

        expect(subject.coins[300]).to be 5
      end
    end
  end
end
