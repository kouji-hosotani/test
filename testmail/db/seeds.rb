# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = [
  {
    :email => "admin@example.com", :encrypted_password => "$2a$10$cAlUeR0b9ZNg0ilcDNsbgea1uvCWtn7.u7ZuJ88/bNawxX/VhEddC",
    :reset_password_token => nil, :reset_password_sent_at => nil,
    :remember_created_at => nil, :sign_in_count => 0,
    :current_sign_in_at => Time.now, :last_sign_in_at => Time.now,
    :current_sign_in_ip => "127.0.0.1", :last_sign_in_ip => "127.0.0.1",
    :deleted_at => nil, :expired_at => nil, :last_visited_at => nil
  }
]
users.each do |value|
  user = User.find_or_initialize_by(email: value[:email])
  if user.new_record?
    user.encrypted_password = value[:encrypted_password]
    user.reset_password_token = value[:reset_password_token]
    user.reset_password_sent_at = value[:reset_password_sent_at]
    user.remember_created_at = value[:remember_created_at]
    user.sign_in_count = value[:sign_in_count]
    user.current_sign_in_at = value[:current_sign_in_at]
    user.last_sign_in_at = value[:last_sign_in_at]
    user.current_sign_in_ip = value[:current_sign_in_ip]
    user.last_sign_in_ip = value[:last_sign_in_ip]
    user.deleted_at = value[:deleted_at]
    user.expired_at = value[:expired_at]
    user.last_visited_at = value[:last_visited_at]
    user.save(validate: false)
  end
end

profiles = {
            :user_id        => 1,
            :name_sei       => "funyufunyu",
            :name_sei_read  => "funyufunyu",
            :name_mei       => "hogehoge",
            :name_mei_read  => "hogehoge",
            :company_id     => 1,
            :auth_type_id   => 1,
            :del_flag       => 0
           }
Profile.find_or_create_by!(profiles)

["register_interim", "register_complete", "reset_password_interim", "reset_password_complete"].each do |value|
  TicketMode.find_or_create_by!(name: value)
end

["new", "gen", "used"].each do |value|
  TicketStatus.find_or_create_by!(name: value)
end

com = [{:id => 1, :name_ja => "ニュートンコンサルティング"}]
com.each do |value|
  Company.find_or_create_by!(id: value[:id], name_ja: value[:name_ja])
end

send_status = [
  {:id => 1, :name_ja => "未送信"},
  {:id => 2, :name_ja => "送信済"},
  {:id => 3, :name_ja => "送信エラー"},
  {:id => 4, :name_ja => "アドレスエラー"},
]
send_status.each do |value|
  SendStatus.find_or_create_by!(id: value[:id], name_ja: value[:name_ja])
end

open_status = [
  {:id => 1, :name_ja => "未開封"},
  {:id => 2, :name_ja => "開封済"},
]
open_status.each do |value|
  OpenStatus.find_or_create_by!(id: value[:id], name_ja: value[:name_ja])
end

attached_types = [
  {:id => 1, :name_ja => "添付なし"},
  {:id => 2, :name_ja => "Word"},
  {:id => 3, :name_ja => "Excel"},
  {:id => 4, :name_ja => "Word(zip圧縮)"},
  {:id => 5, :name_ja => "Excel(zip圧縮)"},
]
attached_types.each do |value|
  AttachedTypes.find_or_create_by!(id: value[:id], name_ja: value[:name_ja])
end

send_time_zone = [
  {:id => 1, :start_time_at => "00:00", :end_time_at => "03:00", :display_name => "00:00 ~ 03:00"},
  {:id => 2, :start_time_at => "03:00", :end_time_at => "06:00", :display_name => "03:00 ~ 06:00"},
  {:id => 3, :start_time_at => "06:00", :end_time_at => "09:00", :display_name => "06:00 ~ 09:00"},
  {:id => 4, :start_time_at => "09:00", :end_time_at => "12:00", :display_name => "09:00 ~ 12:00"},
  {:id => 5, :start_time_at => "12:00", :end_time_at => "15:00", :display_name => "12:00 ~ 15:00"},
  {:id => 6, :start_time_at => "15:00", :end_time_at => "18:00", :display_name => "15:00 ~ 18:00"},
  {:id => 7, :start_time_at => "18:00", :end_time_at => "21:00", :display_name => "18:00 ~ 21:00"},
  {:id => 8, :start_time_at => "21:00", :end_time_at => "00:00", :display_name => "21:00 ~ 00:00"},
]
send_time_zone.each do |value|
  SendTimeZone.find_or_create_by!(id: value[:id], start_time_at: value[:start_time_at], end_time_at: value[:end_time_at], display_name: value[:display_name])
end
