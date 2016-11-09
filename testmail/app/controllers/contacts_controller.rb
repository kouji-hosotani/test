class ContactsController < ApplicationController
  def new
    @errors = {}
    @contact = Contact.new

    render :partial => "new"
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.valid?
      @contact.request = request
      if @contact.deliver
        message = 'Thank you for your message. We will contact you soon!'
        render :json => {:status => 1, :message => message}
      else
        message = 'Cannot send message.'
        render :json => {:status => -1, :message => message}
      end
    else
      @errors = @contact.errors.each_with_object({}) { |(key, value), new_hash| new_hash[key] = value}
      render :json => {:status => 0, :errors => @errors}
    end
  end
end
