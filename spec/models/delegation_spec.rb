require 'spec_helper'

describe Delegation do
  it "should not save without name" do
    d = build(:delegation, name: nil, step: 2)
    expect(d.save).to be false
  end

  it "should be creatable" do
    d = create(:delegation)
    expect(d.save).to be true
  end

  context "with late registration enabled" do
    let(:reg_date_opt) { Option.where(slug: 'late_registration_date').first_or_create(class_name: 'Date') }

    before do
      reg_date_opt = Option.where(slug: 'late_registration_date').first_or_create(class_name: 'Date')
      @old_reg_date_value = reg_date_opt.value
      reg_date_opt.value = Time.now.strftime('%Y-%m-%d')
      reg_date_opt.save
    end

    context 'when delegation is late' do
      before do
        Timecop.freeze(Date.today + 1.week)
      end

      it 'should set delegation is_late_delegation to true' do
        d = create(:delegation)
        expect(d.is_late_delegation).to be_true
      end

      it 'should add any new delegates as late delegates' do
        d = nil
        Timecop.travel(2.weeks.ago) do
          d = create(:delegation, delegation_size: 10)
        end
        puts "DATE TODAY: #{Date.today}"
        d.update_attributes({
          delegation_size: 12
        })
        expect(d.late_delegate_count).to eq 2
      end

      it 'should properly adjust late delegates when delegate count decreases' do
        d = nil
        Timecop.travel(2.weeks.ago) do
          d = create(:delegation, delegation_size: 10, late_delegate_count: 5)
        end
        puts "DATE TODAY: #{Date.today}"
        d.update_attributes({
          delegation_size: 7
        })
        expect(d.late_delegate_count).to eq 2
        d.update_attributes({
          delegation_size: 4
        })
        expect(d.late_delegate_count).to eq 0
      end

      it 'should add any new advisors as late advisors' do
        d = nil
        Timecop.travel(2.weeks.ago) do
          d = create(:delegation)
        end
        a = build(:advisor)
        a.delegation_id = d.id
        a.save
        d.reload
        expect(d.late_advisor_count).to eq 1
      end

      it 'should properly adjust late advisors when advisor count decreases' do
        d = nil
        Timecop.travel(2.weeks.ago) do
          d = create(:delegation, delegation_size: 10, late_advisor_count: 2, advisor_count: 4)
        end

        d.advisors.last.destroy
        expect(d.late_advisor_count).to eq 1

        d.advisors.last.destroy
        d.advisors.last.destroy
        expect(d.late_advisor_count).to eq 0
      end

      after do
        Timecop.return
      end
    end

    context 'when delegation is not late' do
      before do
        Timecop.freeze(1.week.ago)
      end

      it 'should set delegation is_late_delegation to false' do
        d = create(:delegation)
        expect(d.is_late_delegation).to be_false
      end

      it 'should not change late delegate count on a delegation size increase' do
        d = build(:delegation)
        d.update_attributes({
          delegation_size: 10
        })
        expect(d.late_delegate_count).to eq 0
      end

      it 'should not change late advisor count on an advisor count increase' do
        d = create(:delegation)
        a = build(:advisor)
        a.delegation_id = d.id
        a.save
        d.reload
        expect(d.late_advisor_count).to eq 0
      end

      after do
        Timecop.return
      end
    end

    after do
      if @old_reg_date_value
        reg_date_opt.value = @old_reg_date_value
        reg_date_opt.save
      else
        reg_date_opt.destroy
      end
    end
  end

  describe "notifications" do
    it "should send notification on create" do
      d = build(:delegation, name: 'Test Delegation', advisor_count: 0)
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

      email_text = notification.text_part.decoded.gsub(/\n/, ' ')

      expect(email_text).to include(%Q{Delegation updated:})
      expect(email_text).to include(%Q{Test Field:})
      expect(email_text).to include(%Q{Value set to "Test"})
      expect(email_text).not_to include(%Q{Delegation set to "})
      expect(email_text).to include(%Q{Country set to "#{country.name}"})
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
