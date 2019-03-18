# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sighrax::PortableDocumentFormat, type: :model do
  subject { described_class.send(:new, noid, entity) }

  let(:noid) { double('noid') }
  let(:entity) { double('entity') }

  it { is_expected.to be_a_kind_of(Sighrax::Asset) }
  it { expect(subject.resource_type).to eq :PortableDocumentFormat }
  it { expect(subject.resource_id).to eq noid }
end
