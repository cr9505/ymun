require 'spec_helper'

describe Committee do
  describe '.handle_committee_parser' do
    context 'with countries' do
      before do
        parse_result = {
          'countries' => {
            'Country A' => ['Committee 1', 'Committee 2'],
            'Country B' => ['Committee 1', 'Committee 3'],
            'Country C' => ['Committee 2', 'Committee 3'],
          }
        }
        @sync_errors = Committee.handle_committee_parser(parse_result)
        @country_a = MUNCountry.find_by(name: 'Country A')
        @country_b = MUNCountry.find_by(name: 'Country B')
        @country_c = MUNCountry.find_by(name: 'Country C')

        @committee_1 = Committee.find_by(name: 'Committee 1')
        @committee_2 = Committee.find_by(name: 'Committee 2')
        @committee_3 = Committee.find_by(name: 'Committee 3')
      end

      it 'should properly create countries' do
        expect(@country_a).not_to be_nil
        expect(@country_b).not_to be_nil
        expect(@country_c).not_to be_nil
      end

      it 'should properly create committees' do
        expect(@committee_1).not_to be_nil
        expect(@committee_2).not_to be_nil
        expect(@committee_3).not_to be_nil
      end

      it 'should properly assign committees to countries' do
        expect(@country_a.committees.exists?(id: @committee_1.id)).to be_true
        expect(@country_a.committees.exists?(id: @committee_2.id)).to be_true
        expect(@country_b.committees.exists?(id: @committee_1.id)).to be_true
        expect(@country_b.committees.exists?(id: @committee_3.id)).to be_true
        expect(@country_c.committees.exists?(id: @committee_2.id)).to be_true
        expect(@country_c.committees.exists?(id: @committee_3.id)).to be_true
      end

      it 'should not incorrectly assign any committees' do
        expect(@country_a.committees.exists?(id: @committee_3.id)).to be_false
        expect(@country_b.committees.exists?(id: @committee_2.id)).to be_false
        expect(@country_c.committees.exists?(id: @committee_1.id)).to be_false
      end
    end
    context 'with delegations' do
      before do
        @delegation = create(:delegation)
        parse_result = {
          'delegations' => {
            @delegation.id => {
              'characters' => [
                {
                  'name' => 'Character 1',
                  'committees' => ['Committee 1', 'Committee 2']
                },
                {
                  'name' => 'Character 2',
                  'committees' => ['Committee 2']
                }
              ],
              'countries' => ['Country A', 'Country B']
            }
          }
        }
        @sync_errors = Committee.handle_committee_parser(parse_result)
        @character_1 = Character.find_by(name: 'Character 1')
        @character_2 = Character.find_by(name: 'Character 2')

        @committee_1 = Committee.find_by(name: 'Committee 1')
        @committee_2 = Committee.find_by(name: 'Committee 2')

        @country_a = MUNCountry.find_by(name: 'Country A')
        @country_b = MUNCountry.find_by(name: 'Country B')
      end

      it 'should properly create all characters' do
        expect(@character_1).not_to be_nil
        expect(@character_2).not_to be_nil
      end

      it 'should properly create all committees' do
        expect(@committee_1).not_to be_nil
        expect(@committee_2).not_to be_nil
      end

      it 'should properly create all countries' do
        expect(@country_a).not_to be_nil
        expect(@country_b).not_to be_nil
      end

      it 'should properly assign characters to delegations' do
        expect(@character_1.delegation_id).to be(@delegation.id)
        expect(@character_2.delegation_id).to be(@delegation.id)
      end

      it 'should properly assign countries to delegations' do
        expect(@country_a.delegation_id).to be(@delegation.id)
        expect(@country_b.delegation_id).to be(@delegation.id)
      end

      it 'should properly assign characters to committees' do
        expect(@character_1.committees.exists?(id: @committee_1.id)).to be_true
        expect(@character_1.committees.exists?(id: @committee_2.id)).to be_true
        expect(@character_2.committees.exists?(id: @committee_1.id)).to be_false
        expect(@character_2.committees.exists?(id: @committee_2.id)).to be_true
      end
    end
  end
end
