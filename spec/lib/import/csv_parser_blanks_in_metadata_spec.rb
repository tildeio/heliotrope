# frozen_string_literal: true

require 'rails_helper'
require 'import/csv_parser'
require 'metadata_fields' unless defined?(MONO_FILENAME_FLAG) # solves loading issue when this spec is run solo

describe Import::CSVParser do
  let(:input_file) { File.join(fixture_path, 'csv', 'import_blanks', 'tempest_blanks.csv') }
  let(:parser) { described_class.new(input_file) }

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  describe 'initializer' do
    it 'has an input file' do
      expect(parser.file).to eq input_file
    end
  end

  describe '#attributes' do
    subject { parser.attributes }

    it 'collects attributes from the CSV file' do
      expect(subject['title']).to eq ['The Tempest: A Subtitle']
      expect(subject['creator']).to eq ['Shakespeare, William']
      expect(subject['files']).to eq ['shipwreck.jpg', 'miranda.jpg']
      expect(subject['files_metadata']).to eq [
        { 'title' => ['The shipwreck scene in Act I, Scene 1'],
          'creator' => ["Smith\nGal, Another"] },
        { 'title' => ['Miranda'],
          'creator' => ['Waterhouse, John William'] }
      ]
    end
  end
end
