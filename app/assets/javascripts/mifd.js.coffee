window.Mifd =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: -> 
    window.Mifd.Routers.router = new Mifd.Routers.Tweets
    Backbone.history.start()
$(document).ready ->
  Mifd.initialize()

$(document).on 'page:load', ->
  Backbone.history.stop()
  Mifd.initialize()
