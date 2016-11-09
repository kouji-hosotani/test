#= require active_admin/base

$(document).on "ready page:load", ->

  hideEmailInfo()

  showEmailInfo() if $("#information_is_mail:checked").val()
    
  $("#information_is_mail").click ->
    if $("#information_is_mail:checked").val()
      showEmailInfo()
    else
      hideEmailInfo()


showEmailInfo = ->
  $("#information_subject_input").show()
  $("#information_body_input").show()

hideEmailInfo = ->
  $("#information_subject_input").hide()
  $("#information_body_input").hide()

