require 'test_helper'

class DelegationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test "new advisor should make a delegation" do
    confirmed_advisor = users(:confirmed_advisor)

    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in(confirmed_advisor)

    assert_nil confirmed_advisor.delegation


    get :edit, step: 1

    assert_redirected_to new_delegation_path
  end
end