class Staff < ActiveRecord::Base
  belongs_to :company

  scope :enable, -> {where :del_flag => 0}
  scope :company_filter, -> {where :company_id => User.current_user.profile.company_id}

  CIPHER = 'aes-256-cbc'

  def create_name
    out_text = ""
    if self.name_sei.present?
      out_text += self.name_sei
      out_text += " "
    end
    if self.name_mei.present?
      out_text += self.name_mei
    end
    out_text.strip
  end

  def encrypt_id
    encrypt self.id
  end

  def decrypt_id
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.encrypt_secure_key, CIPHER)
    crypt.decrypt_and_verify self.id
  end


  def encrypt(id)
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.encrypt_secure_key, CIPHER)
    crypt.encrypt_and_sign(id)
  end

  class << self
    def decrypt(id)
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.encrypt_secure_key, CIPHER)
      crypt.decrypt_and_verify(id)
    end
  end

end
