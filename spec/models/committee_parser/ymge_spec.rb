require 'spec_helper'

describe CommitteeParser::YMGE do

  context 'with a well-formed committee document' do
    let(:worksheets) do
      worksheet_cells = [
        ['Name', 'Position 1', 'Position 2', 'Position 3'],
        ['Delegation 1', 'A: A', 'B: A', 'B: B'],
        ['Delegation 2', 'C: C', 'A:B', 'A: C']
      ]
      worksheet = double()
      worksheet.stub(:num_rows) { 3 }
      worksheet.stub(:num_cols) { 4 }
      worksheet.stub(:[]) { |row, col| worksheet_cells[row - 1][col - 1] }
      [worksheet]
    end

    it 'should properly parse a well-formed committee document' do
      result = CommitteeParser::YMGE.parse(worksheets)
      expected_result = {
        'Delegation 1' => { 'A' => ['A'], 'B' => ['A', 'B']},
        'Delegation 2' => { 'C' => ['C'], 'A' => ['B', 'C']},
      }
      expect(result).to eq(expected_result)
    end
  end

end