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
      
      friend_likes = facebook_friend_likes
      #@friend_likes = []
      #100.times do |i|
      #  @friend_likes << friend_likes[i%friend_likes.count]
      #end
      @friend_likes = friend_likes
      @friend_likes = [] if (@friend_likes.nil?)
      @total_friends = facebook_friend_count
      if current_user.nil?
        redirect_to :action => :login 
      else
        current_user.facebook_users = []
        current_user.save
        @friend_likes.each do |friend|
          FacebookFriend.create(:facebook_user_id => current_user.id, :friend_id => friend.id)
        end
        @romney_rate = (100.00*@friend_likes.count/@total_friends+0.00).round(2)
        current_user.num_friends = @total_friends
        current_user.romney_rate = @romney_rate
        current_user.save
        redirect_to :action => :login if current_user.nil?
        @current_user = current_user        
      end
    end
  end
  
  def show
    
  end
  
  def sorry
    session['facebook_access_token'] = nil
    session[:last_seen] = nil
    render :text => 'Sorry...'
  end
  
  def login
    if params[:permalink]
      id = params[:permalink].alphadecimal
      @u = FacebookUser.find(id)
      @friend_likes = @u.facebook_users
      @total_friends = @u.num_friends
      @romney_rate = @u.romney_rate
    end
    session['facebook_access_token'] = nil
    session[:last_seen] = nil
  end
  
  def get_current_user
    render :json => {:success => true, :current_user => current_user.as_json(:authenticated)}
  end
  
  def illco
  end
  
end
