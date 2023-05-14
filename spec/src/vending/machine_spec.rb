# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../src/vending'

describe Vending::Machine do
  let(:vending_machine) { described_class.new(stock:, coins:) }
  let(:stock) { [{ id: 1, formatted_name: 'Iced Latte', price: 200, qty: item_count }] }
  let(:item_count) { 10 }
  subject { vending_machine.process }

  before(:each) do
    allow(vending_machine).to receive(:handle_out_of_stock).and_call_original
    allow(vending_machine).to receive(:give_out_item).and_call_original
    allow(vending_machine).to receive_message_chain(:gets, :chomp).and_return(*user_input)
  end

  context 'when user decides not to order' do
    let(:coins) { { 200 => 0 } }
    let(:item_count) { 0 }
    let(:user_input) { %w[test 0] }

    it 'exits' do
      expect(vending_machine.monitor).to receive(:exit_message)

      subject

      expect(vending_machine).not_to have_received(:give_out_item)
    end
  end

  context 'when out of stock' do
    let(:item_count) { 0 }
    let(:coins) { { 25 => 0 } }
    let(:user_input) { %w[1 0] }

    it 'prints out of stock message' do
      expect(vending_machine).to receive(:handle_out_of_stock)

      subject
    end
  end

  context 'when item in stock' do
    let(:coins) { { 200 => 0 } }
    let(:user_input) { %w[1 200 0] }

    it 'gives out an item' do
      subject

      expect(vending_machine).to have_received(:give_out_item)
      expect(stock.first[:qty]).to eq(9)
    end
  end

  context 'when user needs change' do
    let(:coins) { { 25 => 10, 50 => 10, 200 => 10, 300 => 10 } }
    let(:user_input) { %w[1 50 50 50 25 300 0] }

    it 'gives out an item' do
      subject

      expect(vending_machine).to have_received(:give_out_item)
      expect(coins).to eq({ 25 => 10, 50 => 12, 200 => 9, 300 => 11 })
    end
  end

  context 'when out of change' do
    context 'when user needs change' do
      let(:coins) { { 200 => 0, 300 => 0 } }
      let(:user_input) { %w[1 300 0] }

      it 'does not give out an item' do
        subject

        expect(vending_machine).not_to have_received(:give_out_item)
      end

      it 'returns coins from the till' do
        subject

        expect(coins).to eq({ 200 => 0, 300 => 0 })
      end
    end

    context 'when user finds exact coin amount after needing change' do
      let(:coins) { { 25 => 0, 50 => 0, 200 => 0, 300 => 0 } }
      let(:user_input) { %w[1 300 1 50 50 50 25 25 0] }

      it 'gives out an item once' do
        subject

        expect(vending_machine).to have_received(:give_out_item).once
      end
    end

    context 'when user needs change after providing coins' do
      let(:coins) { { 25 => 0, 50 => 0, 100 => 0, 200 => 0, 300 => 0 } }
      let(:user_input) { %w[1 50 50 50 25 100 0] }

      it 'gives out an item' do
        subject

        expect(vending_machine).to have_received(:give_out_item)
        expect(coins).to eq({ 25 => 0, 50 => 2, 100 => 1, 200 => 0, 300 => 0 })
      end
    end
  end
end
