class AdminMailer < ActionMailer::Base
  default :from => '"Meeps" <no-reply@meeps.com>'
  
  def new_user(user)
    @user = user
    mail(
      :to => 'seanzehnder@gmail.com, mat@meeps.com',
      :subject => 'New User Registration'
    )
  end
  
  def broker_deactivated(broker)
    @broker = broker
    mail(
    :to => 'sean@meeps.com, seanzehnder@gmail.com, mat@meeps.com',
    :subject => 'CRITICAL - Broker Deactivated - Needs Attention'
    )
  end
  
end
