class UserMailer < ActionMailer::Base
  default :from => '"Meeps" <howdy@meeps.com>'
  
  def new_user(user)
    @user = user
    mail(
      :to => @user.email,
      :subject => 'Thanks for Joining Meeps!'
    )
  end
  
end
