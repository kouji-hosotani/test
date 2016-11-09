# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#js-sended-mail').click ->
    $("#js-sended-mail-modal").modal("show")

  $('#report_filter_form').keyup (e) ->
    $(this).submit()

  $('#report_filter_form').on 'ajax:success', (event, data, status, xhr) ->
    get_data = data["data"]
    html = ""
    for val, i in get_data
      html += "<tr><td>#{val[0]}</td>"
      html += "<td>#{val[13]}</td>"
      html += "<td>#{val[1]}</td>"
      html += "<td>#{val[2]}</td>"
      html += "<td>#{val[3]}</td>"
      html += "<td>#{val[4]}</td>"
      html += "<td>#{val[5]}</td>"
      html += "<td>#{val[6]}</td>"
      if val[7] != ""
        html += "<td>#{val[7]}</td>"
        html += "<td>#{val[8]}</td>"
      if val[9] != ""
        html += "<td>#{val[9]}</td>"
        html += "<td>#{val[10]}</td>"
      if val[11] != ""
        html += "<td>#{val[11]}</td>"
        html += "<td>#{val[12]}</td>"
      html += "</tr>"

    $("#js-report-tbody").html html
