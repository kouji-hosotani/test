class ApiController < ApiBaseController
  
  def station
    user_id = params[:user_id]

    render :json => Station.all
  end

  def unit
    user_id = params[:user_id]
    station_id = params[:station_id]

    if station_id.blank?
      render :json => {:code => 404, :message => "param is invalid."} 
      return 
    end

    render :json => Unit.where(:station_id => station_id)
  end
end
