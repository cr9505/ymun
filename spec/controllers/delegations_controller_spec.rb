require 'spec_helper'

describe DelegationsController do
  describe 'PUT #update' do
    it "should update current user's delegation's properties" do
      d = create(:delegation)
      u = create(:advisor, :confirmed, delegation_id: d.id)
      pages = create_list(:delegation_page, 4)
      sign_in(u)
      put :update, step: 1, delegation: { name: 'Changed delegation name' }
      d.reload
      expect(d.name).to eq 'Changed delegation name'
    end
  end
end
