require 'spec_helper'

describe Delegation do
  it "should not save without name" do
    d = build(:delegation, name: nil)
    expect(d.save).to be false
  end

  describe "notifications" do
    it "should send notification on create" do
      d = build(:delegation, name: 'Test Delegation')
      d.send_notification = true
      d.advisors << create(:advisor, :confirmed)
      expect { d.save }.to change { ActionMailer::Base.deliveries.size }.by(1)

      notification = ActionMailer::Base.deliveries.last

      expect(notification.subject).to eq "YMGE Notifier: Delegation (ID=#{d.id})"
      expect(notification.to[0]).to eq Option.get('main_email')
      expect(notification.text_part.decoded).to match /Delegation created:/
      expect(notification.text_part.decoded).to match /Name: Test Delegation/
    end

    it "should send notification on update" do
      d = create(:delegation)
      d.send_notification = true
      d.advisors << create(:advisor, :confirmed)
      df = create(:delegation_field, name: 'Test Field')
      country = create(:mun_country)
      attributes = {
        fields_attributes: [{ delegation_field_id: df.id, value: 'Test' }],
        preferences_attributes: [{ country_id: country.id }]
      }
      expect { d.update_attributes(attributes) }.to change { ActionMailer::Base.deliveries.size }.by(1)

      notification = ActionMailer::Base.deliveries.last

      expect(notification.subject).to eq "YMGE Notifier: Delegation (ID=#{d.id})"
      expect(notification.to[0]).to eq Option.get('main_email')
      expect(notification.text_part.decoded).to match /Delegation updated:/
      expect(notification.text_part.decoded).to match /Test Field:/
      expect(notification.text_part.decoded).to match /Value set to "Test"/
      expect(notification.text_part.decoded).not_to match /Delegation set to "/
      expect(notification.text_part.decoded).to match /Country set to "#{country.name}"/
    end

    it "should not send notification if send_notification is false" do
      d = create(:delegation)
      d.advisors << create(:advisor, :confirmed)
      df = create(:delegation_field, name: 'Test Field')
      country = create(:mun_country)
      attributes = {
        fields_attributes: [{ delegation_field_id: df.id, value: 'Test' }],
        preferences_attributes: [{ country_id: country.id }]
      }
      expect { d.update_attributes(attributes) }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end
end
