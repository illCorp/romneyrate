#= require jquery
#= require jquery_ujs
#= require plugins/jquery.color
#= require facebook
#= require plugins/jquery.center

RomneyIndex =
  total_friends_rect: null
  init: ->
    $('#logout').click((event)->
      FacebookLogin.logout()
    )
    this.updateBarGraph(window.FansOfRomney.length,window.TotalFriendCount)
  updateBarGraph: (romney_fans, total_friends)->
    console.log("updateBarGraph...");
    pct = 100*romney_fans/total_friends
    $('#romney_fans_div').animate({width: "#{pct}%"}, 3000, -> 
      console.log("done animating")
    )
    $('#total_friends_div').animate({width: '100%'}, 3000, -> 
      console.log("done animating")
    )
    setTimeout(->
      $('#total_friends .label').animate({color: '#222'}, 1000)
    , 2000)
    
    jQuery({someValue: 0}).animate({someValue: pct}, {duration: 3000, easing: 'swing', step: ->
      $('#percent_label').text("#{this.someValue.toFixed(2)}%")
    })
    
    jQuery({someValue: 0}).animate({someValue: total_friends}, {duration: 3000, easing: 'swing', step: ->
      $('#total_friends .count').text("#{Math.ceil(this.someValue)}")
    })

    jQuery({someValue: 0}).animate({someValue: romney_fans}, {duration: 3000, easing: 'swing', step: ->
      $('#romney_fans .count').text("#{Math.ceil(this.someValue)}")
    })
    

    
      
    
    


window.RomneyIndex = RomneyIndex 

$(document).ready(->
  RomneyIndex.init()
)