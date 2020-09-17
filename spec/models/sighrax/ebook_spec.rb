# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sighrax::Ebook, type: :model do
  subject { ebook }

  let(:ebook) { described_class.send(:new, noid, data) }
  let(:noid) { 'validnoid' }
  let(:data) { {} }

  it { is_expected.to be_an_instance_of(described_class) }
  it { is_expected.to be_a_kind_of(Sighrax::Asset) }
  it { expect(subject.resource_type).to eq :Ebook }
end
