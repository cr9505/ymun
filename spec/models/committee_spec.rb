require 'spec_helper'

describe Committee do
  describe '.handle_committee_parser' do
    context 'with no previous data' do
      before do
        @delegation = create(:delegation)
        parse_result = {
          @delegation.id => [
            {
              'name' => 'Character 1',
              'seat_count' => 1,
              'committees' => ['Committee 1', 'Committee 2']
            },
            {
              'name' => 'Character 2',
              'seat_count' => 2,
              'committees' => ['Committee 2']
            }
          ]
        }
        @sync_errors = Committee.handle_committee_parser(parse_result)
        @character_1 = Character.find_by(name: 'Character 1')
        @character_2 = Character.find_by(name: 'Character 2')

        @committee_1 = Committee.find_by(name: 'Committee 1')
        @committee_2 = Committee.find_by(name: 'Committee 2')
      end

      it 'should properly create all characters' do
        expect(@character_1).not_to be_nil
        expect(@character_2).not_to be_nil
      end

      it 'should properly create all committees' do
        expect(@committee_1).not_to be_nil
        expect(@committee_2).not_to be_nil
      end

      it 'should properly assign characters to delegations' do
        @seat1 = 
        expect(@character_1.delegation_id).to be(@delegation.id)
        expect(@character_2.delegation_id).to be(@delegation.id)

        expect(Seat.where(delegation_id: @delegation.id, character_id: @character_1.id).count).to be(1)
        expect(Seat.where(delegation_id: @delegation.id, character_id: @character_2.id).count).to be(2)
      end

      it 'should properly assign characters to committees' do
        expect(@character_1.committees.exists?(id: @committee_1.id)).to be_true
        expect(@character_1.committees.exists?(id: @committee_2.id)).to be_true
        expect(@character_2.committees.exists?(id: @committee_1.id)).to be_false
        expect(@character_2.committees.exists?(id: @committee_2.id)).to be_true
      end
    end
    context 'with previous data' do
      before do
        @delegation = create(:delegation)
        @character = create(:character, seat_count: 1, name: 'Character 1')
        @seat = Seat.find_or_create_for(@delegation, @character).first
        @seat.delegate = create(:delegate)
        @seat.save
        @delegation.delegates << @seat.delegate
        parse_result = {
          @delegation.id => [
            {
              'name' => @character.name,
              'seat_count' => 2,
              'committees' => ['Committee 1', 'Committee 2']
            },
            {
              'name' => 'Character 2',
              'seat_count' => 1,
              'committees' => ['Committee 1', 'Committee 2']
            }
          ]
        }
        @sync_errors = Committee.handle_committee_parser(parse_result)
      end

      it 'should maintain delegate assignments that already exist' do
        @seat.reload
        expect(@seat).not_to be_nil
        expect(@seat.delegate.delegation_id).to be(@delegation.id)
        expect(@seat.character.id).to be(@character.id)
      end

      it 'should properly add new seats' do
        @character.reload
        expect(@delegation.seats.count).to be(3)
        expect(@character.seat_count).to be(2)
        expect(@character.seats.count).to be(2)
        character2 = Character.find_by(name: 'Character 2')
        character2_seat = Seat.find_by(character_id: character2.id, delegation_id: @delegation.id)
        expect(character2_seat).not_to be_nil
      end
    end
  end
end
