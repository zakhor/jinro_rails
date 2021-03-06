require 'rails_helper'

RSpec.describe VillagesController, type: :controller do
  let(:user) { create(:confirmed_user) }
  let(:other_user) { create(:confirmed_user) }
  let(:valid_attributes) { attributes_for(:village).merge(user_id: user.to_param) }
  let(:invalid_attributes) { attributes_for(:invalid_village).merge(user_id: user.to_param) }

  describe "GET #index" do
    before do
      sign_in(user)
    end

    it "returns a success response" do
      village = Village.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    before do
      sign_in(user)
    end

    it "returns a success response" do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    context 'with valid user' do
      before do
        sign_in(user)
      end

      it "returns a success response" do
        village = Village.create! valid_attributes
        get :edit, params: {id: village.to_param}
        expect(response).to be_successful
      end
    end

    context 'with a user who does not have the village' do
      before do
        sign_in(other_user)
      end

      it "redirects to villages" do
        village = Village.create! valid_attributes
        get :edit, params: {id: village.to_param}
        expect(response).to redirect_to(villages_url)
      end
    end
  end

  describe "POST #create" do
    before do
      sign_in(user)
    end

    context "with valid params" do
      it "creates a new Village" do
        expect {
          post :create, params: {village: valid_attributes}
        }.to change(Village, :count).by(1)
      end

      it "redirects to the created village" do
        post :create, params: {village: valid_attributes}
        expect(response).to redirect_to(villages_path)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: {village: invalid_attributes}
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context 'with valid user' do
      before do
        sign_in(user)
      end

      context "with valid params" do
        let(:new_attributes) {
          {discussion_time: 20}
        }

        it "updates the requested village" do
          village = Village.create! valid_attributes
          put :update, params: {id: village.to_param, village: new_attributes}
          village.reload
          expect(village.discussion_time).to be 20
        end

        it "redirects to the room_for_all" do
          village = Village.create! valid_attributes
          put :update, params: {id: village.to_param, village: valid_attributes}
          expect(response).to redirect_to(village_path(village))
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'edit' template)" do
          village = Village.create! valid_attributes
          put :update, params: {id: village.to_param, village: invalid_attributes}
          expect(response).to be_successful
        end
      end
    end

    context 'with a user who does not have the village' do
      before do
        sign_in(other_user)
      end

      it "redirects to villages" do
        village = Village.create! valid_attributes
        put :update, params: {id: village.to_param, village: valid_attributes}
        expect(response).to redirect_to(villages_url)
      end
    end
  end

  describe "DELETE #destroy" do
    context 'with valid user' do
      before do
        sign_in(user)
      end

      it "destroys the requested village" do
        village = Village.create! valid_attributes
        expect {
          delete :destroy, params: {id: village.to_param}
        }.to change(Village, :count).by(-1)
      end

      it "redirects to the villages list" do
        village = Village.create! valid_attributes
        delete :destroy, params: {id: village.to_param}
        expect(response).to redirect_to(villages_url)
      end
    end

    context 'with a user who does not have the village' do
      before do
        sign_in(other_user)
      end

      it "redirects to root" do
        village = Village.create! valid_attributes
        delete :destroy, params: {id: village.to_param}
        expect(response).to redirect_to(villages_url)
      end
    end
  end

end
