###
name:    api-connector.js.coffee
purpose: Connect and Get json data from JavaServlet API
### 

class @ApiConnector
  constructor: (host) ->
    @host = host

  getData: (method='GET', data) ->
    console.log("data:", @host, data)
    d = undefined
    query = undefined
    if method == 'POST'
      $.each data, (key, value) ->
        if !query
          query = '?' + key + '=' + value
        else
          query += '&' + key + '=' + value 
        return
    else
      #postData = JSON.stringify(setOptFlg(data, type))
  
    url = location.href + "/api/" + method
    
    #loading
    #$('#loading').show()
    
    jQuery.support.cors = true;
    $.ajax
      type: method
      url:  url
      contentType: 'application/json'
      #data: postData
      data: query
      dataType: "json"
      timeout: 360000   #1hour
      success: (d) ->
        console.log("d:", d)
        if d["resultCode"] == "1"
          #redrow(d, type)
        else
          if d["errorMsg"]
            window.error(d["errorMsg"])
          else
            errNo = 1001
            window.error(gon.error[errNo])
          
        # remove loading
        #$('#loading').hide()
        
      error: (e) ->
        errNo = 1001
        window.error(gon.error[errNo])

      dataType: 'json'
      
    return d
  