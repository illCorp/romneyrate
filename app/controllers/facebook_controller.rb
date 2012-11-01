#require 'koala'
class FacebookController < ApplicationController
  
  def index
  end


  def login
    request_token = oauth_consumer.get_request_token(:oauth_callback => TWITTER_CONFIG['callback_url'])

    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    
    redirect_to request_token.authorize_url
  end

  def finalize
     if params[:authResponse]=="null"
       redirect_to '/'
     else
      auth = JSON.parse(params[:authResponse]).with_indifferent_access
      session['facebook_access_token'] = auth[:accessToken]
      session[:last_seen] = Time.now
      redirect_to '/'
    end
  end 
  
  def logout
    session['facebook_access_token'] = nil
    session[:last_seen] = nil
    session[:auth_token] = nil
    render :json => {:success => true}
  end

  private
  
  def get_graph(token)
    Koala::Facebook::API.new(token)
  end
  
end
