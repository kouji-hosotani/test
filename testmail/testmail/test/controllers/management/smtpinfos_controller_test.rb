require 'test_helper'

class Management::SmtpinfosControllerTest < ActionController::TestCase
  setup do
    @management_smtpinfo = management_smtpinfos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_smtpinfos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_smtpinfo" do
    assert_difference('Management::Smtpinfo.count') do
      post :create, management_smtpinfo: {  }
    end

    assert_redirected_to management_smtpinfo_path(assigns(:management_smtpinfo))
  end

  test "should show management_smtpinfo" do
    get :show, id: @management_smtpinfo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_smtpinfo
    assert_response :success
  end

  test "should update management_smtpinfo" do
    patch :update, id: @management_smtpinfo, management_smtpinfo: {  }
    assert_redirected_to management_smtpinfo_path(assigns(:management_smtpinfo))
  end

  test "should destroy management_smtpinfo" do
    assert_difference('Management::Smtpinfo.count', -1) do
      delete :destroy, id: @management_smtpinfo
    end

    assert_redirected_to management_smtpinfos_path
  end
end
