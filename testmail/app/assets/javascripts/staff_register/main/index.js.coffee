# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#staffs-upload').click ->
    $("#staffs-upload-modal").modal("show")
    
  $('#result_form').keyup (e) ->
    $(this).submit()
    
  $('#result_form').on 'ajax:success', (event, data, status, xhr) ->
    get_data = data["data"]
    html = ""
    i = 0
    while i < get_data.length
      item = get_data[i]
      html += "<tr><th>#{i+1}</th><td>#{item["email"]}</td><td>#{item["name_sei"]}</td><td>#{item["name_mei"]}</td>"
      html += "<td>#{item["unit"]}</td><td>#{item["department"]}</td><td>#{item["region"]}</td><td>#{item["post"]}</td>"
      html += "<td><a href=\"/staff_register/profile/#{item["id"]}/edit\">編集</a>| "
      html += "<a data-confirm=\"削除してよろしいでしょうか？\" rel=\"nofollow\" data-method=\"delete\" href=\"/staff_register/profile/#{item["id"]}\">削除</a></td>"
      i++
      
    $("tbody").html html
    
  # Upload csv file.
  $('#file_csv').fileupload
    dropZone: $('#upload'),
    url: "/staff_register/import_csv",
    add: (e, data) ->
      
      upload_file = data["files"][0]
      console.log upload_file
      upload_file_name = upload_file["name"]
      d = new Date( upload_file["lastModified"] )  
      year  = d.getFullYear()
      month = d.getMonth() + 1
      day  = d.getDate()
      hour = if d.getHours()   < 10 then '0' + d.getHours()   else d.getHours()
      min  = if d.getMinutes() < 10 then '0' + d.getMinutes() else d.getMinutes()
      sec  = if d.getSeconds() < 10 then '0' + d.getSeconds() else d.getSeconds()
      date = year + '-' + month + '-' + day + ' ' + hour + ':' + min + ':' + sec
      
      $("#bars").append('
          <div class="bar-list">
            <div class="row">
              <div class="col-md-4">
                <div class="file-name">
                  <p>' + upload_file["name"] + '</p>
                </div>
              </div>
              <div id="bar" class="col-md-4">
                <div class="file-size">
                  <p>' + date + '</p>
                </div>
              </div>
              <div id="bar" class="col-md-4">
                <div class="file-size">
                  <p>' + parseInt(upload_file["size"]) / 1000 + ' KB</p>
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-md-12">
                <div class="progress">
                  <div aria-valuemax="100" aria-valuemin="0" class="progress-bar progress-bar-info" role="progressbar" style="width: 0%;"></div>
                </div>
              </div>
            </div>
          </div>
      ')
      
      data.submit()
              
    start: ->
      $(".alert.alert-danger").hide()
      
    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $(".progress-bar.progress-bar-info").animate {
        width: progress + '%'
      }
    done: (e, data) ->
      $(".progress-bar.progress-bar-info").animate {
        width: '100%'
      }
      location.reload(true)
      
    fail: (e, data) ->
      message = data.jqXHR.responseJSON.message
      $(".alert.alert-danger").html(message)
      $(".alert.alert-danger").show()
