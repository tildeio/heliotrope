# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work Monograph`
require 'rails_helper'

describe Hyrax::Actors::MonographActor do
  subject { Hyrax::CurationConcern.actor(monograph, ::Ability.new(user)) }

  let(:user) { create(:user) }
  let(:monograph) { Monograph.new }
  let(:admin_set) { create(:admin_set, with_permission_template: { with_active_workflow: true }) }

  describe "create" do
    before do
      stub_out_redis
    end

    context "with a non-public visibility" do
      let(:attributes) do
        { title: ["Things About Stuff"],
          press: "heliotrope",
          visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      end

      it "adds default group read and edit permissions" do
        subject.create(attributes)

        expect(monograph.read_groups).to match_array ["heliotrope_admin", "heliotrope_editor"]
        expect(monograph.edit_groups).to match_array ["heliotrope_admin", "heliotrope_editor"]
      end

      it "updates to public" do
        attributes["visibility"] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        subject.update(attributes)

        expect(monograph.read_groups).to include("public")
      end
    end

    context "with a public visibility" do
      let(:attributes) do
        { title: ["Things About Stuff"],
          press: "heliotrope",
          visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      end

      it "adds default group read and edit permissions including public read" do
        subject.create(attributes)

        expect(monograph.read_groups).to match_array ["heliotrope_admin", "heliotrope_editor", "public"]
        expect(monograph.edit_groups).to match_array ["heliotrope_admin", "heliotrope_editor"]
      end

      it "updates with a new group" do
        (attributes["edit_groups"] ||= []).push("anotherpress_editor")
        subject.update(attributes)

        expect(monograph.edit_groups).to match_array ["heliotrope_admin", "heliotrope_editor", "anotherpress_editor"]
      end

      it "updates to private" do
        attributes["visibility"] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        subject.update(attributes)

        expect(monograph.read_groups).to_not include("public")
      end
    end
  end
end