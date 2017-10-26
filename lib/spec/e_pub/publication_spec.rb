# frozen_string_literal: true

require 'byebug'

RSpec.describe EPub::Publication do
  describe "without a test epub" do
    let(:noid) { 'validnoid' }
    let(:non_noid) { 'invalidnoid' }
    let(:epub) { double("epub") }
    let(:validator) { double("validator") }

    before do
      allow(EPub::Cache).to receive(:cache).with(noid, epub).and_return(nil)
      allow(EPub::Cache).to receive(:cached?).with(noid).and_return(true)

      allow(EPub::Validator).to receive(:from).and_return(validator)
      allow(validator).to receive(:id).and_return(noid)
      allow(validator).to receive(:content_file).and_return(true)
      allow(validator).to receive(:content).and_return(true)
      allow(validator).to receive(:toc).and_return(true)
    end

    # Class Methods

    describe '#clear_cache' do
      it { expect(described_class).to respond_to(:clear_cache) }
    end

    describe '#from' do
      subject { described_class.from(data) }

      context 'null object' do
        context 'non hash' do
          context 'nil' do
            let(:data) { nil }

            it 'returns an instance of PublicationNullObject' do
              is_expected.to be_an_instance_of(EPub::PublicationNullObject)
            end
          end
          context 'non-noid' do
            let(:data) { non_noid }

            it 'returns an instance of PublicationNullObject' do
              is_expected.to be_an_instance_of(EPub::PublicationNullObject)
            end
          end
        end
        context 'hash' do
          context 'empty' do
            let(:data) { {} }

            it 'returns an instance of PublicationNullObject' do
              is_expected.to be_an_instance_of(EPub::PublicationNullObject)
            end
          end
          context 'nil' do
            let(:data) { { id: nil } }

            it 'returns an instance of PublicationNullObject' do
              is_expected.to be_an_instance_of(EPub::PublicationNullObject)
            end
          end
          context 'non-noid' do
            let(:data) { { id: non_noid } }

            it 'returns an instance of PublicationNullObject' do
              is_expected.to be_an_instance_of(EPub::PublicationNullObject)
            end
          end
        end
      end

      context 'publication' do
        context 'non hash' do
          let(:data) { noid }

          it 'returns an instance of a Publication' do
            is_expected.to be_an_instance_of(described_class)
          end
        end
        context 'hash' do
          let(:data) { { id: noid } }

          it 'returns an instance of a Publication' do
            is_expected.to be_an_instance_of(described_class)
          end
        end
      end
    end

    describe '#new' do
      it 'private_class_method' do
        expect { is_expected }.to raise_error(NoMethodError)
      end
    end

    describe '#null_object' do
      subject { described_class.null_object }

      it 'returns an instance of PublicationNullObject' do
        is_expected.to be_an_instance_of(EPub::PublicationNullObject)
      end
    end

    # Instance Methods

    describe '#id' do
      subject { described_class.from(noid).id }
      it 'returns noid' do
        is_expected.to eq noid
      end
    end

    describe '#presenter' do
      subject { described_class.from(noid).presenter }

      it 'returns an publication presenter' do
        is_expected.to be_an_instance_of(EPub::PublicationPresenter)
        expect(subject.id).to eq noid
      end
    end

    describe '#purge' do
      subject { described_class.from(noid).purge }
      it { is_expected.to be nil }
    end

    describe '#read' do
      subject { described_class.from(noid).read(file_entry) }

      let(:path) { double("path") }
      let(:path_entry) { double("path_entry") }
      let(:file_entry) { double("file_entry") }
      let(:text) { double("text") }

      before do
        allow(File).to receive(:exist?).with(path_entry).and_return(true)
        allow(FileUtils).to receive(:touch).with(path)
        allow(File).to receive(:read).with(path_entry).and_return(text)
        allow(::EPub).to receive(:path_entry).with(noid, file_entry).and_return(path_entry)
        allow(::EPub).to receive(:path).with(noid).and_return(path)
      end

      context 'returns text' do
        it { is_expected.to eq text }
      end

      context 'standard error' do
        before do
          @message = 'message'
          allow(File).to receive(:read).with(path_entry).and_raise("StandardError")
          allow(EPub.logger).to receive(:info).with(any_args) { |value| @message = value }
        end

        it 'returns null object read' do
          is_expected.not_to eq text
          is_expected.to eq described_class.null_object.read(file_entry)
          expect(@message).not_to eq 'message'
          expect(@message).to eq 'Publication.read(#[Double "file_entry"]) in publication validnoid raised StandardError'
        end
      end
    end

    describe '#search' do
      subject { instance.search(query) }

      let(:instance) { described_class.from(noid) }
      let(:search)  { double("search") }
      let(:query) { double("query") }
      let(:results) { double("results") }

      before do
        allow(EPub::Search).to receive(:new).with(instance).and_return(search)
        allow(search).to receive(:search).with(query).and_return(results)
      end

      context 'epubs search service returns results' do
        it 'returns results' do
          is_expected.to eq results
        end
      end

      context 'epubs search service raises standard error' do
        before do
          allow(search).to receive(:search).with(query).and_raise(StandardError)
          @message = 'message'
          allow(EPub.logger).to receive(:info).with(any_args) { |value| @message = value }
        end

        it 'returns null object query' do
          is_expected.not_to eq results
          is_expected.to eq described_class.null_object.search(query)
          expect(@message).not_to eq 'message'
          expect(@message).to eq 'Publication.search(#[Double "query"]) in publication validnoid raised StandardError'
        end
      end
    end
  end

  describe "with a test epub" do
    before do
      @id = '999999999'
      @file = './spec/fixtures/fake_epub01.epub'
      described_class.from(id: @id, file: @file)
    end

    after do
      described_class.from(@id).purge
    end

    describe "#chapters" do
      subject { described_class.from(@id) }
      it "has 3 chapters" do
        expect(subject.chapters.count).to be 3
      end

      describe "the first chapter" do
        # It's a little wrong to test this here, but Publication has the logic
        # that populates the Chapter object, so it's here. For now.
        subject { described_class.from(@id).chapters[0] }
        it "has the id of" do
          expect(subject.chapter_id).to eq "Chapter01"
        end
        it "has the href of" do
          expect(subject.chapter_href).to eq "xhtml/Chapter01.xhtml"
        end
        it "has the title of" do
          expect(subject.title).to eq 'Damage report!'
        end
        it "has the basecfi of" do
          expect(subject.basecfi).to eq '/6/2[Chapter01]!'
        end
        it "has the chapter doc" do
          expect(subject.doc.name).to eq 'document'
          expect(subject.doc.xpath("//p")[2].text).to eq "Computer, belay that order"
        end
      end
    end
  end
end
