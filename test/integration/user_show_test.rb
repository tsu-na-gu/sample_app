require "test_helper"

class UserShowTest < ActionDispatch::IntegrationTest

  def setup
    @inactive_user = users(:inactive)
    @activated_user = users(:archer)
  end

  test "should redirect when user not inactivated" do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "should display user when activated" do
    log_in_with_param(@activated_user)
    get user_path(@activated_user)
    assert_response :success
    assert_template 'users/show'
  end

  test "should be display the follow stats in show" do
    log_in_with_param(@activated_user)
    get user_path(@activated_user)
    assert_select 'strong#following'
    assert_select 'strong#followers'
  end
end
