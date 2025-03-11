require 'rails_helper'

RSpec.describe WishlistsController, type: :controller do
  login_user

  let(:group) { create(:group, user: controller.current_user) }
  let(:participant) { create(:participant, group: group, user: controller.current_user) }
  let(:item) { create(:item) }
  let(:wishlist) { create(:wishlist, participant: participant) }
  let!(:wishlist_item) { create(:wishlist_item, wishlist: wishlist, item: item) }

  describe 'GET #index' do
    it 'returns a list of wishlists for the participant' do
      get :index, format: :json, params: { group_id: group.id, participant_id: participant.id }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.first['wishlist']['participant_id']).to eq(participant.id)
    end

    it 'handles non-existent participant' do
      get :index, format: :json, params: { 
        group_id: group.id, 
        participant_id: 999999
      }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq(I18n.t('errors.record_not_found'))
    end       
  end

  describe 'GET #show' do
    context 'when user is authorized' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:show?).and_return(true)
      end

      it 'returns the wishlist details' do
        get :show, params: { group_id: group.id, participant_id: participant.id, id: wishlist.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['wishlist']['id']).to eq(wishlist.id)
        expect(json_response['wishlist']['is_owner']).to be true
      end

      it 'includes wishlist items' do
        get :show, params: { group_id: group.id, participant_id: participant.id, id: wishlist.id }

        json_response = JSON.parse(response.body)
        expect(json_response['wishlist']['items']).to be_present
        expect(json_response['wishlist']['items'].first['id']).to eq(item.id)
      end
    end

    context 'when user is not authorized' do
      let(:other_user) { create(:user) }
      let(:other_group) { create(:group, user: other_user) }
      let(:other_participant) { create(:participant, user: other_user, group: other_group) }
      let!(:other_wishlist) { create(:wishlist, :with_items, participant: other_participant) }

      before do
        allow_any_instance_of(WishlistPolicy).to receive(:show?).and_return(false)
      end

      it 'returns forbidden status' do
        get :show, format: :json, params: { 
          id: other_wishlist.id,
          group_id: other_group.id,
          participant_id: other_participant.id
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    let(:item) { create(:item) }
    let(:valid_params) do
      {
        participant_id: participant.id,
        wishlist: {
          wishlist_items_attributes: [
            { item_id: item.id.to_s }
          ]
        }
      }
    end

    context 'with valid parameters' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:create?).and_return(true)
        allow_any_instance_of(Wishlists::WishlistService).to receive(:create_with_items)
          .and_return({ 
            success: true, 
            wishlist: build_stubbed(:wishlist, participant: participant) 
          })
      end
      it 'creates a new wishlist' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:created)
      end

      it 'calls the wishlist service' do
        expected_params = ActionController::Parameters.new(
          wishlist_items_attributes: [
            { item_id: item.id.to_s }
          ]
        ).permit(wishlist_items_attributes: [:id, :item_id, :_destroy])
        
        expect_any_instance_of(Wishlists::WishlistService)
          .to receive(:create_with_items)
          .with(expected_params)
        
        post :create, params: valid_params, format: :json
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:create?).and_return(true)
        allow_any_instance_of(Wishlists::WishlistService).to receive(:create_with_items)
          .and_return({ 
            success: false, 
            error: "Creation failed" 
          })
      end

      it 'returns unprocessable entity status' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_item) { create(:item) }
    let(:valid_update_params) do
      {
        id: wishlist.id,
        participant_id: participant.id,
        wishlist: {
          wishlist_items_attributes: [
            { id: wishlist_item.id, _destroy: '1' },
            { item_id: new_item.id.to_s }
          ]
        },
        format: :json
      }
    end

    context 'when user is authorized' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:update?).and_return(true)
        allow_any_instance_of(Wishlists::WishlistService)
          .to receive(:update_wishlist)
          .and_return({
            success: true,
            wishlist: WishlistSerializer.new(wishlist.reload).format_wishlist_details
          })
      end

      it 'updates the wishlist' do
        patch :update, params: valid_update_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not authorized' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:update?).and_return(false)
      end

      it 'returns forbidden status' do
        patch :update, params: valid_update_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is authorized' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:destroy?).and_return(true)
      end

      it 'deletes the wishlist' do
        delete :destroy, params: { id: wishlist.id, format: :json }
        expect(response).to have_http_status(:no_content)
        expect(Wishlist.exists?(wishlist.id)).to be false
      end
    end

    context 'when user is not authorized' do
      before do
        allow_any_instance_of(WishlistPolicy).to receive(:destroy?).and_return(false)
      end

      it 'returns forbidden status' do
        delete :destroy, params: { id: wishlist.id, format: :json }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end 
