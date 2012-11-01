class AdminMailer < ActionMailer::Base
  default :from => '"Whats My Romney Rating" <no-reply@whatsmyromneyrating.com>'
  
  def new_user(user)
    @user = user
    mail(
      :to => 'seanzehnder@gmail.com, mat@meeps.com',
      :subject => 'New User Registration'
    )
  end 
 
end
