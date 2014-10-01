module CommitteeParser
  class YMGE
    def self.parse(worksheets)
      ws = worksheets[0]
      delegation_hash = {}
      num_rows = ws.num_rows
      num_cols = ws.num_cols
      for row in 2..ws.num_rows
        delegation = ws[row, 1]
        delegation_id = ws[row, 2].to_i
        delegation_hash[delegation_id] ||= []
        for col in 5..ws.num_cols
          committee_and_position = ws[row, col]
          next unless committee_and_position && committee_and_position[/:/, 0]
          *committees, position = committee_and_position.split(':')
          committees.map {|c| c.strip! }
          position.strip!
          delegation_hash[delegation_id] << {
            'name' => position,
            'seat_count' => 1,
            'committees' => committees
          }
        end
      end
      delegation_hash
    end
  end
end
