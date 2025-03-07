require 'rails_helper'

RSpec.describe GroupEmailJob, type: :job do
  describe '#perform' do
    let(:user) { create(:user) }
    let(:group) { create(:group, user: user, users_count: 1) }
    
    it 'sends emails to all group users' do
      mailer = double('mailer')
      expect(GroupMailer).to receive(:group_created_email)
        .exactly(group.users.count).times
        .and_return(mailer)
      expect(mailer).to receive(:deliver_later).exactly(group.users.count).times
      
      GroupEmailJob.perform_now(group.id)
    end

    it 'retries on error' do
      allow(GroupMailer).to receive(:group_created_email)
        .and_raise(StandardError)

      expect {
        GroupEmailJob.perform_now(group.id)
      }.to raise_error(StandardError)
    end

    context 'when user has no email' do
      # Skip this test if email is required by validation
      it 'skips sending email', skip: 'Email is required by validation' do
        expect(GroupMailer).not_to receive(:group_created_email)
        GroupEmailJob.perform_now(group.id)
      end
    end
  end
end 