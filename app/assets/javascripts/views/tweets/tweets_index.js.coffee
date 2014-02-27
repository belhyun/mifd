class Mifd.Views.TweetsIndex extends Backbone.View
  template: JST['tweets/index']

  el: 'body .content-main'

  events:
    'click .tweet-actions li .retweet,.tweet-actions li .favorite': 'tweet_action'

  initialize: ->
    $("img").error ->
      $(this).attr "src","/assets/designer.jpg"
    (enableSelectBoxes = ->
      $("div.selectBox").each ->
        $(this).children("span.selected").html $(this).children("div.selectOptions").children("span.selectOption:first").html()
        $(this).attr "value", $(this).children("div.selectOptions").children("span.selectOption:first").attr("value")
        $(this).children("span.selected,span.selectArrow").click ->
          if $(this).parent().children("div.selectOptions").css("display") is "none"
            $(this).parent().children("div.selectOptions").css "display", "block"
          else
            $(this).parent().children("div.selectOptions").css "display", "none"
          return
        $(this).find("span.selectOption").click ->
          $(this).parent().css "display", "none"
          $(this).closest("div.selectBox").attr "value", $(this).attr("value")
          $(this).parent().siblings("span.selected").html $(this).html()
          $(".content-main .content-header .header-inner").removeAttr("style")
          return
        return
      return
    )()

  mifd_dialog: (id, ok, cancel) ->
    $(id).dialog
      resizable: false
      height: 180
      modal: true
      buttons:
        Ok: ->
          ok $(this)
        Cancel: ->
          $(this).dialog "close"

  is_login: ->
    @.mifd_dialog "#dialog-confirm",(->
      location.href = "/auth/twitter"
    )

  already_request: ->
    @.mifd_dialog "#dialog-already",(that)->
      that.dialog.call that , "close"

  tweet_action: (event) ->
    event.preventDefault()
    that = this
    if(!gon.current_user)
      @.is_login()
    else
      index = $(event.currentTarget).parents('.content').parent('li').index()
      tweet = @collection.at(index)
      chk = (if ($(event.currentTarget).attr("class") is "retweet") then "is_retweet" else "is_favorite")
      if(!tweet.get(chk))
        user_tweet = new Mifd.Models.UserTweet(
          user_desc: gon.current_user.screen_name
          type:(if $(event.currentTarget).attr("class") is "retweet" then "R" else "F")
          tweet_uuid:tweet.get('uuid')
        )
        $("#spinner,#modal").css("display","block")
        user_tweet.save null,
          success: (model,response) ->
            $("#spinner,#modal").css("display","none")
            if(Number(response.result))
              if chk == 'is_retweet'
                tweet.set
                  'is_retweet': true
              else
                tweet.set
                 'is_favorite': true
              that.mifd_dialog "#dialog-success",(that)->
                that.dialog.call that , "close"
            else
              @.already_request()
       else
         $("#spinner,#modal").css("display","none")
         @.already_request()
