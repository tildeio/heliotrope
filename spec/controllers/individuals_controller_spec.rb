# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe IndividualsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Individual. As you add validations to Individual, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { identifier: "valid_identifier", name: "valid_name", email: "valid_email" } }
  let(:invalid_attributes) { { identifier: "", name: "", email: "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # IndividualsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      _individual = Individual.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      individual = Individual.create! valid_attributes
      get :show, params: { id: individual.to_param }, session: valid_session
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_success
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      individual = Individual.create! valid_attributes
      get :edit, params: { id: individual.to_param }, session: valid_session
      expect(response).to be_success
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Individual" do
        expect {
          post :create, params: { individual: valid_attributes }, session: valid_session
        }.to change(Individual, :count).by(1)
      end

      it "redirects to the created individual" do
        post :create, params: { individual: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Individual.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { individual: invalid_attributes }, session: valid_session
        expect(response).to be_success
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { identifier: "new_identifier" } }

      it "updates the requested individual" do
        individual = Individual.create! valid_attributes
        put :update, params: { id: individual.to_param, individual: new_attributes }, session: valid_session
        individual.reload
        expect(individual.identifier).to eq("new_identifier")
      end

      it "redirects to the individual" do
        individual = Individual.create! valid_attributes
        put :update, params: { id: individual.to_param, individual: valid_attributes }, session: valid_session
        expect(response).to redirect_to(individual)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        individual = Individual.create! valid_attributes
        put :update, params: { id: individual.to_param, individual: invalid_attributes }, session: valid_session
        expect(response).to be_success
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested individual" do
      individual = Individual.create! valid_attributes
      expect {
        delete :destroy, params: { id: individual.to_param }, session: valid_session
      }.to change(Individual, :count).by(-1)
    end

    it "redirects to the individuals list" do
      individual = Individual.create! valid_attributes
      delete :destroy, params: { id: individual.to_param }, session: valid_session
      expect(response).to redirect_to(individuals_url)
    end
  end
end
