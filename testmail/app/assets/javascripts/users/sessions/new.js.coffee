$ ->
  $("#user_password").keypress (e) ->
    if e.keyCode == 13
      document.loginForm.submit()