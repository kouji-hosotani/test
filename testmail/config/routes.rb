Rails.application.routes.draw do

  # root 'top/main#index'
  root "mail_history/main#index"

  # devise
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :passwords => 'users/passwords',
    :sessions => 'users/sessions'
  }

  devise_scope :user do
    get   '/users/sign_up/interim' => "users/registrations#interim"
    post  '/users/sign_up/interim' => "users/registrations#interim_create"
    get   '/users/sign_up/interim/result' => "users/registrations#interim_result"
    get   '/users/sign_up/result' => "users/registrations#result"
    get   '/users/profile/edit' => "users/registrations#profile_edit"
    put   '/users/profile' => "users/registrations#profile_update"
    patch   '/users/profile' => "users/registrations#profile_update"
    post  '/users/station/' => "users/registrations#station_create"
    post  '/users/station/:station_id/unit' => "users/registrations#unit_create"
    get   '/users/password/result' => "users/passwords#result"
    get   '/users/password/update_result' => "users/passwords#update_result"
    # sessions.
    get   '/users/sign_out' => 'users/sessions#destroy'
  end

  # 管理画面
  namespace :management do
    get "smtpinfo" => 'smtpinfo#index'
    put "smtpinfo/edit" => 'smtpinfo#edit'
  end

  # メール送信履歴
  namespace :mail_history do
    get "" => "main#index"
    post "get_filter_data" => "main#get_filter_data"
    resources :reserve, controller: 'main', only: [:destroy] do
    end
  end

  # 社員登録
  namespace :staff_register do
    get "" => "main#index"
    post "import_csv" => "main#import_csv"
    post "get_filter_data" => "main#get_filter_data"
    get "export_csv" => "main#export_csv"
    resources :profile, controller: 'main', only: [:new, :edit, :destroy, :create, :update] do
    end
  end

  # メール雛形作成
  resources :mail_template, controller: 'mail_template/main' do
    post "/get_data" => "mail_template/main#get_data"
  end

  namespace :mail_template do
    post "get_filter_data" => "main#get_filter_data"
  end

  # メール予約
  namespace :mail_reservation do
    get "" => "main#index"
    post "" => "main#create"
    post "get_mail_message" => "main#get_mail_message"
  end

  # 開封レポート
  namespace :open_report do
    get ":id"         => "main#show"
    get "export_csv/:id" => "main#export_csv", as: "export"
    post "get_filter_data/:id" => "main#get_filter_data", as: "get_filter_data"
  end

  # beacon
  namespace :beacon do
    get "/"         => "main#index"
  end

  # health_check
  get '/health_check' => 'application#health_check'

  # error
  get '*anything' => 'errors#routing_error'

end
