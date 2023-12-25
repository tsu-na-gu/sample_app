require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_with_param(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password: "foo",
                                              password_confirmation: "bar" } }
    assert_select ".alert", text: /The form contains 4 errors./
  end

  test "successful edit with frindly forwarding" do
    get edit_user_path(@user)
    log_in_with_param(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "forward reading should happen in one time" do
    get edit_user_path(@user)
    assert_equal session[:fowarding_url], edit_user_url
    log_in_with_param(@user)
    get root_url
    assert_not session[:fowarding_url]
  end
end
