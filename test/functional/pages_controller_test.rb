require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get mobile" do
    get :mobile
    assert_response :success
  end

  test "should get news" do
    get :news
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get terms" do
    get :terms
    assert_response :success
  end
  test "should get signup" do
    get :signup
    assert_response :success
  end


end
