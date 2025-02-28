class GroupMailer < ApplicationMailer
  # default from: "from@example.com"

  def group_created_email(user, group)
    @user = user
    @group = group
    
    @invitation_link = generate_invitation_link if new_user?

    mail(
      to: @user.email,
      subject: t('groups.emails.created.subject')
    )
  end

  private

  def new_user?
    @user.created_at == @user.updated_at
  end

  def generate_invitation_link
    @user.invite! rescue nil
  end
end
