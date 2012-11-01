require 'facebook_methods'
class HomeController < ApplicationController
  # http_basic_authenticate_with name: "meeps", password: "@g3rr3ds3cur3!", except: :index
  before_filter :authenticate_user!, :only => [:get_session, :get_current_user]
  include FacebookMethods
  
  def index
    redirect_to :action => :login unless facebook_authorized?
    session[:last_seen] = Time.now
    if (facebook_authorized?)
      current_user = facebook_user
      @friend_likes = facebook_friend_likes
      @friend_likes = [] if (@friend_likes.nil?)
      #foo = []
      #if @friend_likes.count>0
      #  100.times do |i|
      #    foo << @friend_likes[i%@friend_likes.count]
      #  end
      #end
      #@friend_likes = foo
      @total_friends = facebook_friend_count
      redirect_to :action => :login if current_user.nil?
    end
    @current_user = current_user
  end
  
  def sorry
    session['facebook_access_token'] = nil
    session[:last_seen] = nil
    render :text => 'Sorry...'
  end
  
  def login
    session['facebook_access_token'] = nil
    session[:last_seen] = nil
  end
  
  def get_current_user
    render :json => {:success => true, :current_user => current_user.as_json(:authenticated)}
  end
  
  
end
