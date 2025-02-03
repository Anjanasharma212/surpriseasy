class GroupMailer < ApplicationMailer
  # default from: "from@example.com"

  def group_created_email(user, group)
    @user = user
    @group = group
    
    @invitation_link = @user.invite!
    mail(to: @user.email, subject: 'Your Group Has Been Created!')
  end
end
