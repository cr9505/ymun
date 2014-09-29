require 'spec_helper'

describe CommitteeParser::YMGE do

  context 'with a well-formed committee document' do
    let(:worksheets) do
      worksheet_cells = [
        ['Name', 'ID', 'Position 1', 'Position 2', 'Position 3'],
        ['Delegation 1', '1', 'A: A', 'B: A', 'B: B'],
        ['Delegation 2', '2', 'C: C', 'A:B', 'A: C'],
        ['Delegation 3', '3', 'C: B: C', 'A:B', 'A: C']
      ]
      worksheet = double()
      worksheet.stub(:num_rows) { 4 }
      worksheet.stub(:num_cols) { 5 }
      worksheet.stub(:[]) { |row, col| worksheet_cells[row - 1][col - 1] }
      [worksheet]
    end

    it 'should properly parse a well-formed committee document' do
      result = CommitteeParser::YMGE.parse(worksheets)
      expected_result = {
        1 => {
          'characters' => [
            {
              'name' => 'A',
              'committees' => ['A']
            },
            {
              'name' => 'A',
              'committees' => ['B']
            },
            {
              'name' => 'B',
              'committees' => ['B']
            }
          ]
        },
        2 => {
          'characters' => [
            {
              'name' => 'C',
              'committees' => ['C']
            },
            {
              'name' => 'B',
              'committees' => ['A']
            },
            {
              'name' => 'C',
              'committees' => ['A']
            }
          ]
        },
        3 => {
          'characters' => [
            {
              'name' => 'C',
              'committees' => ['C', 'B']
            },
            {
              'name' => 'B',
              'committees' => ['A']
            },
            {
              'name' => 'C',
              'committees' => ['A']
            }
          ]
        },
      }
      expect(result).to eq(expected_result)
    end
  end

end
