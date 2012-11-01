#= require jquery
#= require jquery_ujs
#= require facebook

RomneyIndex =
  markers: null 
  boundsChangedTimer: null
  init: ->
    $('#logout').click((event)->
      FacebookLogin.logout()
    )
    


window.RomneyIndex = RomneyIndex 

$(document).ready(->
  RomneyIndex.init()
)