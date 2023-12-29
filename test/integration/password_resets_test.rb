require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPsswordFormTest < PasswordResets

  test "password reset path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets
  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  test "reset with valid email" do
    assert_not @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email:"")
    assert_redirected_to root_url
  end

  test "reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "reset with right email but wrong token" do
    get edit_password_reset_path("wrong token", email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  test "password token is valid" do
    assert @reset_user.authenticated?(:reset, @reset_user.reset_token)
  end

  test "updaste with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "foobz", password_confirmation: "barquux" } }
    assert_template 'password_resets/edit'
    assert_select 'div#error_explanation'
  end

  test "update with emptyh password" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "", password_confirmation: "" } }
    assert_template 'password_resets/edit'
    assert_select "div#error_explanation"
  end

  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "foobarbuzz", password_confirmation: "foobarbuzz" } }

    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end

class ExpiredToken < PasswordResets
  def setup
    super
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:      "foobarbuzz",
                            password_confirmation: "foobarbuzz" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "should redirect to the password-reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!
    assert_match /expired/i, response.body
  end
end