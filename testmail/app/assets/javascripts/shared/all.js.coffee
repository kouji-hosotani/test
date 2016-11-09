startDate = ""
endDate = ""
$ ->
  $('.js-btn-submit').click ->
    $("form").submit()

  # help
  $('#jsHelp').click ->
    linkurl = $(this).attr('href')
    if !linkurl.match('javascript')
      window.open linkurl, '_blank'
    return false

  # date picker

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
  weekHeader = '週'
  showWeek = 'true'
  millisecondOffset = 24 * 60 * 60 * 1000
  canPeriod = 90    #選択可能日数

  # Date関連
  format2ymd = (date) ->
    y = date.getFullYear()
    m = ('0' + (date.getMonth() + 1)).slice(-2)
    d = ('0' + date.getDate()).slice(-2)
    format = y + "-" + m + "-" + d
    return format

  #yyyy-mm-dd -> Datetimeにキャスト
  format2date = (ymd) ->
    arr = ymd.split('-')
    y = arr[0]
    m = ('0' + (arr[1] - 1)).slice(-2)
    d = ('0' + arr[2]).slice(-2)
    new Date(y, m, d)

  #日数分(+ or -) を求める
  plsDate = (selected, plsDate, operator) ->
    d = undefined
    dateStr = selected.split("-")
    selDate = new Date( dateStr[0], dateStr[1] - 1 , dateStr[2])

    #minus
    if operator == 'minus'
      d = new Date( selDate.getTime() - millisecondOffset * plsDate)
    #plus
    else
      d = new Date( selDate.getTime() + millisecondOffset * plsDate)

    dateArr = [
      d.getFullYear()
      ('0' + (d.getMonth()+1)).slice(-2)
      ('0' + d.getDate()).slice(-2)
    ]
    date = dateArr[0]+"-"+dateArr[1]+"-"+dateArr[2]

  # エラー表示
  error = (msg) ->
    $.jGrowl.defaults.position = 'top-right';
    $.jGrowl(
      msg,
      {
        life: 1500,
        position: 'top-right',
        animateOpen: { opacity: 'show' },
        #以前のエラーは消去する(遅延する)
        #beforeOpen:(e, m, o) ->
          #$("div.jGrowl").jGrowl("close");
      }
  );

  window.error = error
  window.format2ymd = format2ymd
  window.plsDate = plsDate
