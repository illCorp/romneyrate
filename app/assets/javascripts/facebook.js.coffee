#= require jquery

FacebookLogin =
  currentUser: null
  init: ->
    #console.log('Initializing FacebookLogin')
    fb_js = $("<script src='//connect.facebook.net/en_US/all.js' async='true'></script>")
    $('head').append(fb_js)
    $('#login_button').click((e) ->
      FB.login((resp)->
        console.log('logged in w/ facebook (this is the callback)')
        url = "/facebook/finalize?authResponse=#{JSON.stringify(resp.authResponse)}"
        window.location = url
      , {scope: 'user_about_me, publish_stream, friends_likes'})
    )

  logout: (callback) ->
    FB.logout((resp) ->
      $.ajax(
        url: '/facebook/logout'
        type: 'DELETE'
        success: (resp) ->
          console.log('You are now logged out of Facebook')
          callback() if (callback)
      )
    )
  shareApp: (id) ->
    link = "http://#{window.location.host}/"
    console.log("sharing link: #{link}")
    FB.ui(
      method: 'feed'
      name: 'She'
      link: link
      picture: ''
      description: 'Description of She.org'
      caption: 'www.she.org (this is a caption)' 
    )

window.FacebookLogin = FacebookLogin 


window.fbAsyncInit = ->
  #console.log('fbAsyncInit')
 
  settings = 
    appId      : window.FacebookAppID,
    status     : true, # check login status
    cookie     : true, #enable cookies to allow the server to access the session
    xfbml      : true  # parse XFBML
  FB.init(settings)
  
  if !window.FacebookAuthorized
    FB.getLoginStatus((response) ->
      console.log('')
      if window.AutoLogoutFacebook
        window.FacebookLogin.logout(->
          console.log('Facebook should now be closed')
        )
      #if (response.authResponse)
      #console.log('I know you, yo...')
      #url = "/facebook/finalize?authResponse=#{JSON.stringify(response.authResponse)}"
      #window.location = url
      #else
      #console.log('Halt - I DONT know you...')
    , true)
  FB.Event.subscribe('auth.login', (response) ->
    $('#registration').hide()
    console.log(response)
    url = "/facebook/finalize?authResponse=#{JSON.stringify(response.authResponse)}"
    window.location = url
  )
  FB.Event.subscribe('auth.logout', (response) ->
    #console.error("Facebook logout event observed.  You need to handle this!")
  )
  
$(document).ready ->
  FacebookLogin.init()
  
  