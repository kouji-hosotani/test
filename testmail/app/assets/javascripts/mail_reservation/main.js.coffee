# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("#js-temp").on "change", ->
    post_data = {id: $(@).val()}

    jqXHR = $.ajax({
      async: true
      url:  "/mail_reservation/get_mail_message"
      type: "POST"
      data: post_data
      dataType: 'json'
      cache: false
    })

    jqXHR.done (data, stat, xhr) ->
      console.log { done: stat, data: data, xhr: xhr }
      if data.length > 0
        $("#js-template-subject").val(data[0].subject)
        $("#js-template-message").val(data[0].message)
        if data[0].attach_flag
          $("#js-template-filename").val(data[0].file_name)
          $("#js-template-filename").prop("disabled", false)
        else
          $("#js-template-filename").val("")
          $("#js-template-filename").prop("disabled", true)

  selected_id = '';
  match = location.search.match(/id=(.*?)(&|$)/)
  if match
    selected_id = decodeURIComponent(match[1])
  if selected_id != ''
    $("#js-temp").val(selected_id)
  $("#js-temp").change()

  $("#js-reserve-modal-button").on "click", ->
    staff_num = $(".js-rs-check").filter(":checked").length
    date = $(".datepicker_reserve").val()
    range = $("#js-hour").val()
    hour = range.split("~")[0].trim()
    title = $("#job_name").val().trim()
    file_name = $("#js-template-filename").val().trim()
    error_flg = false

    today = new Date()
    input_date = new Date(date + "T" + hour + ":00+09:00")

    if title == ""
      error("タイトルを入力してください")
      error_flg = true
    # 時刻チェック（過去ではないかチェック）
    if today.getTime() - input_date.getTime() > 0
      error("過去日時は設定できません")
      error_flg = true
    if !$("#js-template-filename").prop("disabled") and file_name == ""
      error("添付ファイル名を入力してください")
      error_flg = true
    if staff_num == 0
      error("送信先を選択してください")
      error_flg = true

    if error_flg
      return false
    else
      sender = $("#js-template-sender").val()
      subject =  $("#js-template-subject").val()
      $("#js-rs-title").text("タイトル：" + title)
      $("#js-rs-time").text("予約送信日時：" + date + " " + range)
      $("#js-rs-sender").text("送信元表示名：" + sender)
      $("#js-rs-subject").text("メール件名：" + subject)
      $("#js-rs-staff").text("送信人数：" + staff_num + "名")
      $("#js-reserve-modal").modal("show")

  $("#js-reserve-button").on "click", ->
    $("#js-reserve-form").submit()

  $(".js-all-check").on "change", ->
    if $(this).is(":checked")
      $(".js-rs-check").prop("checked", true)
    else
      $(".js-rs-check").prop("checked", false)

  $(".js-rs-check").on "change", ->
    if $(".js-rs-check").filter(":checked").length > 0
      $(".js-all-check").prop("checked", true)
      if $(".js-rs-check").length != $(".js-rs-check").filter(":checked").length
        $(".js-all-check").prop("indeterminate", true)
      else
        $(".js-all-check").prop("indeterminate", false)
    else
      $(".js-all-check").prop("checked", false)
      $(".js-all-check").prop("indeterminate", false)

  # for callendar
  firstDay = 1
  numberOfMonths = 2
  dateFormat = 'yy-mm-dd'
  dayNamesMin = [
    '日', '月', '火', '水', '木', '金', '土'
  ]
  dayNames = [
    '日', '月', '火', '水', '木', '金', '土'
  ]
  monthNames = [
    '1月', '2月', '3月'
    '4月', '5月', '6月'
    '7月', '8月', '9月'
    '10月', '11月', '12月'
  ]
  yearSuffix = '年'
  showWeek = 'true'
  millisecondOffset = 24 * 60 * 60 * 1000
  canPeriod = 90    #選択可能日数

  $datepicker_reserve = $(".datepicker_reserve")
  today = format2ymd(new Date)

  # 送信予約用
  $datepicker_reserve.datepicker
    altField: ".datepicker_reserve"
    firstDay: firstDay
    numberOfMonths: numberOfMonths
    dateFormat: dateFormat
    dayNamesMin: dayNamesMin
    dayNames: dayNames
    monthNames: monthNames
    yearSuffix: yearSuffix
    minDate: today

  # 初期値(today)
  $datepicker_reserve.datepicker("setDate", today);
