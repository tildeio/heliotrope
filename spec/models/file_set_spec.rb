require 'rails_helper'

describe FileSet do
  let(:file_set) { described_class.new }
  let(:sort_date) { '2014-01-03' }
  let(:bad_sort_date) { 'NOT-A-DATE' }
  let(:search_year) { '2014' }
  let(:bad_search_year) { 'YEAR' }

  it 'has a valid sort_date' do
    file_set.sort_date = sort_date
    file_set.apply_depositor_metadata('admin@example.com')
    expect(file_set.save!).to be true
    expect(file_set.reload.sort_date).to eq sort_date
  end

  it 'does not have an valid sort date' do
    file_set.sort_date = bad_sort_date
    file_set.apply_depositor_metadata('admin@example.com')
    expect { file_set.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end

  it 'has a valid search year' do
    file_set.search_year = search_year
    file_set.apply_depositor_metadata('admin@example.com')
    expect(file_set.save!).to be true
    expect(file_set.reload.search_year).to eq search_year
  end

  it 'does not have an valid search year' do
    file_set.search_year = bad_search_year
    file_set.apply_depositor_metadata('admin@example.com')
    expect { file_set.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end
end
