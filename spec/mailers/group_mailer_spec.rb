require 'rails_helper'

RSpec.describe GroupMailer, type: :mailer do
  describe '#group_created_email' do
    let(:user) { create(:user) }  # Create user first
    let(:group) { create(:group, user: user) }  # Associate with group
    
    context 'with new user' do
      before do
        user.update_columns(created_at: Time.current, updated_at: Time.current)
      end

      it 'sends invitation for new user' do
        expect(user).to receive(:invite!).and_return('invitation_link')
        mail = GroupMailer.group_created_email(user, group)
        expect(mail.subject).to eq('Your Group Has Been Created!')
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(['from@example.com'])
      end

      it 'handles invitation errors gracefully' do
        expect(user).to receive(:invite!).and_raise(StandardError)
        expect {
          GroupMailer.group_created_email(user, group).deliver_now
        }.not_to raise_error
      end
    end

    context 'with existing user' do
      before do
        user.update_columns(updated_at: 1.day.from_now)
      end

      it 'does not send invitation' do
        expect(user).not_to receive(:invite!)
        GroupMailer.group_created_email(user, group).deliver_now
      end
    end
  end
end 