# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::GrantEditToMembersJob do
  let(:depositor) { create(:user) }
  let(:work) { build(:monograph) }
  let(:file_set_ids) { ['xyz123abc', 'abc789zyx'] }

  before do
    allow_any_instance_of(described_class).to receive(:file_set_ids).with(work).and_return(file_set_ids)
  end

  it 'loops over FileSet IDs, spawning a job for each' do
    file_set_ids.each do |file_set_id|
      expect(Hyrax::GrantEditJob).to receive(:perform_now).with(file_set_id, depositor.user_key).once
    end
    described_class.perform_now(work, depositor.user_key)
  end
end
