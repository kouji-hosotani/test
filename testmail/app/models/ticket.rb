class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :ticket_status
  belongs_to :ticket_mode

  def self.create_ticket key, message
    encryptor = self._get_encryptor key
    return encryptor.encrypt_and_sign(message)
  end
  
  def self.create_ticket_key
    return secret = SecureRandom::hex(50)
  end
    
  def self.is_invalid_ticket_limit key, encrypt_message
    time = self._get_ticket_info key, encrypt_message
    return time > 8.hours.ago(Time.now) ? true : false
  end
  
  def self._get_ticket_info key, encrypt_message
    encryptor = self._get_encryptor key
    return encryptor.decrypt_and_verify(encrypt_message)
  end
  
  def self._get_encryptor key
    return  ::ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-cbc')
  end
  
end
