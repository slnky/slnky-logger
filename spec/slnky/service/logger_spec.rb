require 'spec_helper'

describe Slnky::Service::Logger do
  subject { described_class.new("http://localhost:3000", test_config) }
  let(:test_event) { event_load('test')}

  it 'handles event' do
    expect(subject.handler(test_event.name, test_event.payload)).to eq(true)
  end
end
