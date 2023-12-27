require "test_helper"

# UsersControllerTest
#
# Test class for UsersController
#
# The UsersControllerTest class includes various tests for the UsersController class.
class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_with_param(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_with_param(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_with_param(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: {
                                              passowrd: 'password',
                                              password_confirmation: 'password',
                                              admin: true  } }
    assert_not @other_user.admin?
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should rediret destroy when logged in as non-admin" do
    log_in_with_param(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "index as admin includding pagination and delete links" do
    log_in_with_param(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "index as non-admin" do
    log_in_with_param(@other_user)
    get users_path
    assert_select 'a', text:'delete', count: 0
  end
end
