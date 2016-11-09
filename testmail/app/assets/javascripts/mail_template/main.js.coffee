# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("#js-disp-modal").on "click", ->
    $("#js-template-modal").modal("show")

  $("#js-add-button").on "click", ->
    check_flg = true
    # 件名チェック
    if $.trim($("#js-template-title").val()) == ""
      error("メール件名を入力してください")
      check_flg = false
    # 本文チェック
    message = $("#js-template-message").val()
    if message == ""
      error("本文を入力してください")
      check_flg = false
    # タイプチェック
    if !$('#tra_type_link').prop('checked') and !$('#tra_type_file').prop('checked')
      error("タイプを選択してください")
      check_flg = false
    else
      if $('#tra_type_link').prop('checked')
        if !/<a href='%URL%'>.*<\/a>/.test(message)
          error("本文にリンクタグ<br>（&lt;a href=&#039;%URL%&#039;&gt;〜&lt;/a&gt;）が<br>入力されていません")
          check_flg = false
      if $('#tra_type_file').prop('checked')
        if $.trim($("#js-template-filename").val()) == ""
          error("添付ファイル名を入力してください")
          check_flg = false

    if check_flg
      $("#js-template-form").submit()

  $('#template_filter_form').keyup (e) ->
    $(this).submit()

  $("#js-template-filename").prop("disabled", true)
  $("#js-at-type").prop("disabled", true)
  $('#tra_type_file').on "click", ->
    if $(this).prop('checked')
      $("#js-template-filename").prop("disabled", false)
      $("#js-at-type").prop("disabled", false)
    else
      $("#js-template-filename").prop("disabled", true)
      $("#js-at-type").prop("disabled", true)

  $('#update_tra_type_file').on "click", ->
    if $(this).prop('checked')
      $("#js-template-update-filename").prop("disabled", false)
      $("#js-update-at-type").prop("disabled", false)
    else
      $("#js-template-update-filename").prop("disabled", true)
      $("#js-update-at-type").prop("disabled", true)

  $('#template_filter_form').on 'ajax:success', (event, data, status, xhr) ->
    get_data = data["data"]
    html = ""
    for val, i in get_data
      html += "<tr><td>#{val.id}</td>"
      html += "<td>#{val.subject}</td>"
      if val.link_flag
        html += "<td class='text-center'><span class='glyphicon glyphicon-ok' aria-hidden='true' style='color: red'></span></td>"
      else
        html += "<td class='text-center'><span class='glyphicon glyphicon-minus' aria-hidden='true' style='color: blue'></span></td>"
      if val.attach_flag
        html += "<td class='text-center'><span class='glyphicon glyphicon-ok' aria-hidden='true' style='color: red'></span></td>"
      else
        html += "<td class='text-center'><span class='glyphicon glyphicon-minus' aria-hidden='true' style='color: blue'></span></td>"

      html += "<td>#{val.updated_at}</td>"
      # html += "<td><a class='js-template-update' value='#{val.id}' href='#'>編集</a>| <a data-confirm='削除します。よろしいですか？' rel='nofollow' data-method='delete' href='/mail_template/#{val.id}'>削除</a></td></tr>"
      html += "<td class='text-right'><a class='btn btn-success' href='/mail_reservation?id=#{val.id}'>送信予約</a> <a class='js-template-update btn btn-success' value='#{val.id}' href='#'>編集</a> <a class='btn btn-success' data-confirm='削除します。よろしいですか？' rel='nofollow' data-method='delete' href='/mail_template/#{val.id}'>削除</a></td>"


    $("#js-template-tbody").html html

  $("#js-template-tbody").on "click", ".js-template-update", (e)->
    e.preventDefault()
    $("#js-update-button").attr("value", $(@).attr("value"))
    post_data = {id: $(@).attr("value")}

    jqXHR = $.ajax({
      async: true
      url:  "/mail_template/" + $(@).attr("value") + "/get_data"
      type: "POST"
      data: post_data
      dataType: 'json'
      cache: false
    })

    jqXHR.done (data, stat, xhr) ->
      console.log { done: stat, data: data, xhr: xhr }
      if data.length > 0
        $("#js-template-update-title").val(data[0].subject)
        $("#js-template-update-message").val(data[0].message)
        $("#js-template-update-filename").val(data[0].file_name)
        $("input#update_tra_type_link").prop("checked", data[0].link_flag)
        $("input#update_tra_type_file").prop("checked", data[0].attach_flag)
        $("#js-update-at-type").val(data[0].attached_type_id)

        if data[0].attach_flag
          $("#js-template-update-filename").prop("disabled", false)
          $("#js-update-at-type").prop("disabled", false)
        else
          $("#js-template-update-filename").prop("disabled", true)
          $("#js-update-at-type").prop("disabled", true)

        $("#js-template-update-modal").modal("show")

  $("#js-update-button").on "click", ->
    check_flg = true
    # 件名チェック
    if $.trim($("#js-template-update-title").val()) == ""
      error("メール件名を入力してください")
      check_flg = false
    # 本文チェック
    message = $("#js-template-update-message").val()
    if message == ""
      error("本文を入力してください")
      check_flg = false
    # タイプチェック
    if !$('#update_tra_type_link').prop('checked') and !$('#update_tra_type_file').prop('checked')
      error("タイプを選択してください")
      check_flg = false
    else
      if $('#update_tra_type_link').prop('checked')
        if !/<a href='%URL%'>.*<\/a>/.test(message)
          error("本文にリンクタグ<br>（&lt;a href=&#039;%URL%&#039;&gt;〜&lt;/a&gt;）が<br>入力されていません")
          check_flg = false
      if $('#update_tra_type_file').prop('checked')
        if $.trim($("#js-template-update-filename").val()) == ""
          error("添付ファイル名を入力してください")
          check_flg = false

    if check_flg
      $("#js-template-update-form").attr("action",  "/mail_template/" + $(@).attr("value"))
      $("#js-template-update-form").submit()
