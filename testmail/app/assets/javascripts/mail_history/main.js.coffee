# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#history_filter_form').keyup (e) ->
    $(this).submit()

  $('#history_filter_form').on 'ajax:success', (event, data, status, xhr) ->
    get_data = data["data"]
    html = ""
    for val, i in get_data
      html += "<tr><td>" + (i + 1) + "</td>"
      html += "<td>#{val.job_name}</td>"
      html += "<td>#{val.subject}</td>"
      html += "<td>#{val.reserved_date}</td>"
      html += "<td>#{val.send_time_zone}</td>"
      html += "<td>#{val.send_at}</td>"
      html += "<td>#{val.member_num}</td>"
      html += "<td>#{val.created_at}</td>"
      html += "<td><a class='btn btn-success' href='/open_report/#{val.id}'>詳細</a>"
      if val.send_at == ""
        html += " <a class='btn btn-success' data-confirm='タイトル「#{val.job_name}」を取消してよろしいでしょうか？' rel='nofollow' data-method='delete' href='/mail_history/reserve/#{val.id}'>取消</a>"
      html += "</td></tr>"

    $("#js-history-tbody").html html
