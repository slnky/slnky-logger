require 'spec_helper'

describe Slnky::Logger::Service do
  subject do
    s = described_class.new
    s.client = Slnky::Logger::Mock.new
    s
  end
  let(:test_event) { slnky_event('test')}

  it 'handles event' do
    # test that the handler method receives and responds correctly
    expect(subject.handle_test(test_event.name, test_event.payload)).to eq(true)
  end
end
