require "spec_helper"

describe(Jekyll::Watcher) do
  let(:base_opts) do
    {
      "source"      => source_dir,
      "destination" => dest_dir,
    }
  end

  let(:options) { base_opts }
  let(:site)    { instance_double(Jekyll::Site) }
  let(:default_ignored) { [%r!^_config\.yml!, %r!^_site/!, %r!^\.jekyll\-metadata!] }
  subject { described_class }
  before(:each) do
    FileUtils.mkdir(options["destination"]) if options["destination"]
  end

  after(:each) do
    FileUtils.rm_rf(options["destination"]) if options["destination"]
  end

  describe "#watch" do
    let(:listener) { instance_double(Listen::Listener) }

    let(:opts) do
      { :ignore => default_ignored, :force_polling => options["force_polling"] }
    end

    before do
      allow(Listen).to receive(:to).with(options["source"], opts).and_return(listener)

      allow(listener).to receive(:start)

      allow(Jekyll::Site).to receive(:new).with(options).and_return(site)
      allow(Jekyll.logger).to receive(:info)

      allow(subject).to receive(:sleep_forever)

      subject.watch(options)
    end

    it "starts the listener" do
      expect(listener).to have_received(:start)
    end

    it "sleeps" do
      expect(subject).to have_received(:sleep_forever)
    end

    it "ignores the config and site by default" do
      expect(Listen)
        .to have_received(:to)
        .with(anything, hash_including(:ignore => default_ignored))
    end

    it "defaults to no force_polling" do
      expect(Listen)
        .to have_received(:to)
        .with(anything, hash_including(:force_polling => nil))
    end

    context "with force_polling turned on" do
      let(:options) { base_opts.merge("force_polling" => true) }

      it "respects the custom value of force_polling" do
        expect(Listen)
          .to have_received(:to)
          .with(anything, hash_including(:force_polling => true))
      end
    end
  end

  describe "#watch using site instance" do
    let(:listener) { instance_double(Listen::Listener) }

    let(:opts) { { :ignore => default_ignored, :force_polling => nil } }

    before do
      allow(Listen)
        .to receive(:to)
        .with(options["source"], opts)
        .and_return(listener)

      allow(listener).to receive(:start)

      allow(Jekyll.logger).to receive(:info)

      allow(subject).to receive(:sleep_forever)

      subject.watch(options, site)
    end

    it "does not create a new site instance" do
      expect(listener).to have_received(:start)
    end
  end

  context "#listen_ignore_paths" do
    let(:ignored) { subject.send(:listen_ignore_paths, options) }
    let(:metadata_path) { Jekyll.sanitized_path(options["source"], ".jekyll-metadata") }

    before(:each) { FileUtils.touch(metadata_path) }
    after(:each)  { FileUtils.rm(metadata_path) }

    it "ignores config.yml, .jekyll-metadata, and _site by default" do
      expect(ignored).to eql(default_ignored)
      expect(ignore_path?(ignored, "_site/foo.html")).to eql(true)
      expect(ignore_path?(ignored, "_sitemapper/foo.html")).to eql(false)
      expect(ignore_path?(ignored, "bar/_site/foo.html")).to eql(false)
      expect(ignore_path?(ignored, "bar/_site-mapper.html")).to eql(false)
    end

    context "with something excluded" do
      let(:excluded) { ["README.md", "LICENSE"] }
      let(:excluded_absolute) do
        excluded.map { |p| Jekyll.sanitized_path(options["source"], p) }
      end
      let(:options) { base_opts.merge("exclude" => excluded) }
      before(:each) { FileUtils.touch(excluded_absolute) }
      after(:each)  { FileUtils.rm(excluded_absolute) }

      it "ignores the excluded files" do
        expect(ignore_path?(ignored, "README.md")).to eql(true)
        expect(ignore_path?(ignored, "LICENSE")).to eql(true)
      end
    end

    context "with a custom destination" do
      let(:default_ignored) { [%r!^_config\.yml!, %r!^_dest/!, %r!^\.jekyll\-metadata!] }

      context "when source is absolute" do
        context "when destination is absolute" do
          let(:options) { base_opts.merge("destination" => source_dir("_dest")) }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
            expect(ignore_path?(ignored, "_dest/foo.html")).to eql(true)
            expect(ignore_path?(ignored, "_destination/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest-nation.html")).to eql(false)
          end
        end

        context "when destination is relative" do
          let(:options) { base_opts.merge("destination" => "spec/test-sité/_dest") }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
            expect(ignore_path?(ignored, "_dest/foo.html")).to eql(true)
            expect(ignore_path?(ignored, "_destination/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest-nation.html")).to eql(false)
          end
        end
      end

      context "when source is relative" do
        let(:base_opts) do
          { "source" => Pathname
            .new(source_dir)
            .relative_path_from(Pathname.new(".")
            .expand_path).to_s, }
        end

        context "when destination is absolute" do
          let(:options) { base_opts.merge("destination" => source_dir("_dest")) }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
            expect(ignore_path?(ignored, "_dest/foo.html")).to eql(true)
            expect(ignore_path?(ignored, "_destination/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest-nation.html")).to eql(false)
          end
        end

        context "when destination is relative" do
          let(:options) { base_opts.merge("destination" => "spec/test-sité/_dest") }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
            expect(ignore_path?(ignored, "_dest/foo.html")).to eql(true)
            expect(ignore_path?(ignored, "_destination/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest/foo.html")).to eql(false)
            expect(ignore_path?(ignored, "bar/_dest-nation.html")).to eql(false)
          end
        end
      end
    end
  end
end
