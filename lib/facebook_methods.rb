module FacebookMethods
    
  def facebook_client
    return nil if (session['facebook_access_token'].nil?)
    begin
      @client ||= Koala::Facebook::API.new(session['facebook_access_token'])
    rescue Koala::Facebook::APIError => e
      logger.error e
    end
    return @client
  end
  
  def facebook_user
    return @u if !@u.nil?
    @u = nil
    begin
      if facebook_client
        you = facebook_client.get_object('me')
        if (you)
          results = facebook_client.fql_query("select uid, name, pic_square, pic_big, pic, profile_url from user where uid=#{you['id']}").first
          if (FacebookUser.exists?(:uid => results['uid'].to_s))
            @u = FacebookUser.where(:uid => results['uid'].to_s).first
            @u.update_attributes({name:results['name'], image_url: results['pic_square'], raw_json: results.to_json}, profile_url: results['profile_url'])
            @u.reload
          else
            @u = FacebookUser.new({uid: results['uid'].to_s, name:results['name'], image_url: results['pic_big'], raw_json: results.to_json, profile_url: results['profile_url']})
            @u.save
          end
        end
      end
    rescue Koala::Facebook::APIError => exc
      logger.error exc
    end
    @u
  end
  
  def facebook_friend_count
    user = facebook_user
    if user
      begin
        query = "SELECT friend_count FROM user WHERE uid = me()"
        results = facebook_client.fql_query(query).last
        return results['friend_count']
      rescue Koala::Facebook::APIError => e
        session['facebook_access_token'] = nil
        session[:last_seen] = nil
        redirect_to '/'
        logger.error e
      end
    end
    return 0
  end
  
  def facebook_friends
    user = facebook_user
    if user
      begin
        friend_ids = facebook_client.get_connections("me", "friends").collect {|item| item['id']}
        results = facebook_client.fql_query("select uid, name, pic_square, pic_big, pic, profile_url from user where uid in (#{friend_ids.join(",")})")
        friends = results.collect do |row|
          #item = FacebookUser.find_and_update_or_create_leaf_data({uid: row['uid'], image_url: row['pic_big'], name: row['name'], raw_json: row.to_json, parent_id: user.id, origin: 'Facebook'})
        end
        #Rails.cache.write(user.uid, friends)
        return friends
      rescue Koala::Facebook::APIError => e
        session['facebook_access_token'] = nil
        session[:last_seen] = nil
        redirect_to '/'
        logger.error e
      end
    end
    return []
  end
  
  def facebook_friend_likes
    user = facebook_user
    if user
      begin
        
        query = "SELECT uid, first_name, last_name, pic_big, pic_square, name, profile_url FROM user WHERE uid IN(
        	SELECT uid FROM page_fan WHERE page_id='21392801120' AND uid IN (
        		SELECT uid2 FROM friend WHERE uid1 = me()
        	)
        )"
        results = facebook_client.fql_query(query)
        friends = results.collect do |row|
          if (FacebookUser.exists?(:uid=>row['uid'].to_s))
            u = FacebookUser.where(:uid => row['uid'].to_s).first
            u.update_attributes({name:row['name'], image_url: row['pic_square'], raw_json: row.to_json, profile_url: row['profile_url']})
            u.reload
          else
            u = FacebookUser.new({uid: row['uid'].to_s, name:row['name'], image_url: row['pic_square'], raw_json: row.to_json, profile_url: row['profile_url']})
            u.save
          end
          u
        end
        return friends
      rescue Koala::Facebook::APIError => e
        session['facebook_access_token'] = nil
        session[:last_seen] = nil
        redirect_to '/'
        logger.error e
      end 
    end
    return []
  end
  
  def facebook_authorized?
    !session['facebook_access_token'].nil?
  end
end
