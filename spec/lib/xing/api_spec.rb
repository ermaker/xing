require 'xing'

RSpec.describe Xing::API do
  subject { described_class }
  xit '#account works' do
    expect(subject.account(0)['response']).to be_a(String)
  end

  describe '#tr' do
    xit 't1901 works' do
      expect(subject.tr(:t1901, shcode: '122630')['response']).to be_a(Hash)
    end

    xit 't1901 works with a symbol' do
      expect(subject.tr(:t1901, shcode: :leverage)['response']).to be_a(Hash)
      # expect(subject.tr(:t1901, shcode: :inverse)['response']).to be_a(Hash)
    end

    xit 'CSPAT00600 works' do
      actual = subject.tr(
        :CSPAT00600,
        pass: ENV['ACCOUNT_PASS'],
        shcode: '122630',
        qty: 1,
        sell_or_buy: :sell
      )
      expect(actual['response']).to be_a(Hash)
    end
  end
end
