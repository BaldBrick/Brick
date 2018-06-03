require 'test_helper'

class ComparatorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get comparator_index_url
    assert_response :success
  end

end
