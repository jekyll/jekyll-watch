require 'spec_helper'

describe(Jekyll::Watcher) do
  let(:options) do
    {
      'source' => source_dir,
      'destination' => dest_dir
    }
  end
  subject { described_class }

  context "#build_listener" do
    it "returns a Listen::Listener" do
      expect(subject.build_listener(options)).to be_a(Array)
    end
  end
end
