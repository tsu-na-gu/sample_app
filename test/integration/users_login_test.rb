require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_select "title", text: /Log in/
    post login_path, params: { session: { email: "", password: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert_redirected_to @user
    follow_redirect!
    assert_select "title", text: /Michael Example/
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with email/invalid password" do
    post login_path, params: { session: { email: @user.email,
                                          password: 'wrong_password' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_select "title", text: /Log in/
    get root_path
    assert flash.empty?
  end
end
