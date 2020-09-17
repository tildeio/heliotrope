# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShareEbookPolicy do
  let(:policy) { described_class.new(actor, ebook, ebook_policy: ebook_policy) }
  let(:actor) { instance_double(Anonymous, 'actor', agent_type: 'actor_type', agent_id: 'actor_id') }
  let(:ebook) { instance_double(Sighrax::Ebook, 'ebook', resource_type: 'ebook_type', resource_id: 'ebook_id') }
  let(:ebook_policy) { instance_double(ResourcePolicy, 'ebook_policy', show?: show) }
  let(:show) { false }

  describe '#allowed?' do
    subject { policy.allowed? }

    it { is_expected.to be false }

    context 'when the actor can access the ebook' do
      let(:show) { true }

      it { is_expected.to be false }

      context 'when the press allows sharing' do
        let(:press) { instance_double(Press, allow_share_links?: true) }

        before { allow(Sighrax).to receive(:press).with(ebook).and_return(press) }

        it { is_expected.to be true }
      end
    end
  end
end
