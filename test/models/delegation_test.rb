require 'test_helper'

class DelegationTest < ActiveSupport::TestCase
  test "should not save without name" do
    d = Delegation.new
    assert_not d.save, "Delegation saved without name"
  end

  test "should send notification on create" do
    d = Delegation.new(id: 4, name: 'Test Delegation')
    d.advisors << users(:graham)
    assert_difference 'ActionMailer::Base.deliveries.size', +1, 'Email not sent.' do
      d.save
      puts "heyo"
    end
    notification = ActionMailer::Base.deliveries.last
 
    puts notification.body.inspect

    assert_equal "YMGE Notifier: Delegation (ID=4)", notification.subject
    assert_equal 'recruitment@ymge.org', notification.to[0]
    assert_match(/Delegation created:/, notification.text_part.decoded)
    assert_match(/Name: Test Delegation/, notification.text_part.decoded)
  end
end