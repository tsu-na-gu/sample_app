require "test_helper"

class MicropostControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: {content: "Lorem ipsum" } }
    end
  end

  test "shou redirect destory when not logged in" do
    assert_no_difference "Micropost.count" do
      delete micropost_path(@micropost)
    end
    assert_not is_logged_in?
    assert_redirected_to login_url
    assert_response :see_other
  end

  test "should redirect destroy for wrong micropost" do
  log_in_with_param(users(:michael))
  micropost = microposts(:ants)
  assert_no_difference "Micropost.count" do
    delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end
end

