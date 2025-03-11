require 'rails_helper'

RSpec.describe ParticipantsController, type: :controller do
  login_user

  let(:group) { create(:group, user: controller.current_user) }
  let(:participant) { create(:participant, group: group, user: controller.current_user) }
  
  describe 'GET #show' do
    context 'when participant exists' do
      context 'with drawn name' do
        let(:participant_with_drawn) { create(:participant, :with_drawn_name, group: group) }

        it 'returns participant details with drawn name' do
          get :show, params: { id: participant_with_drawn.id }, format: :json
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['drawn_name']).to be_present
          expect(json_response['participant_id']).to eq(participant_with_drawn.id)
        end
      end

      context 'without drawn name' do
        it 'returns participant details without drawn name' do
          get :show, params: { id: participant.id }, format: :json
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq(I18n.t('participants.errors.no_drawn_name'))
        end
      end
    end

    context 'when participant does not exist' do
      it 'returns not found status' do
        get :show, params: { id: 999999 }, format: :json
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq(I18n.t('participants.errors.not_found'))
      end
    end
  end

  describe 'PATCH #update' do
    context 'when drawing names' do
      let!(:other_participant) { create(:participant, group: group) }

      context 'when successful' do
        it 'draws a name and returns updated participant' do
          patch :update, params: { id: participant.id }, format: :json
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['drawn_name']).to be_present
        end
      end

      context 'when participant already has drawn name' do
        let(:participant_with_drawn) { create(:participant, :with_drawn_name, group: group) }

        it 'returns error message' do
          patch :update, params: { id: participant_with_drawn.id }, format: :json
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']).to eq(I18n.t('participants.errors.already_drawn'))
        end
      end

      context 'when no available participants' do
        before do
          third_participant = create(:participant, group: group)
          other_participant.update!(drawn_name: third_participant)
          third_participant.update!(drawn_name: other_participant)
        end

        it 'returns error message' do
          patch :update, params: { id: participant.id }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']).to eq(I18n.t('participants.errors.no_available_participants'))
        end
      end
    end

    context 'when participant does not exist' do
      it 'returns not found status' do
        patch :update, params: { id: 999999 }, format: :json
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq(I18n.t('participants.errors.not_found'))
      end
    end
  end
end 
