module CommitteeParser
  class YMGE
    def self.parse(worksheets)
      ws = worksheets[0]
      delegation_hash = {}
      for row in 2..ws.num_rows
        delegation = ws[row, 1]
        delegation_id = ws[row, 2].to_i
        delegation_hash[delegation_id] ||= {'characters' => []}
        for col in 3..ws.num_cols
          committee_and_position = ws[row, col]
          *committees, position = committee_and_position.split(':')
          committees.map {|c| c.strip! }
          position.strip!
          delegation_hash[delegation_id]
          delegation_hash[delegation_id]['characters'] << {
            'name' => position,
            'committees' => committees
          }
        end
      end
      delegation_hash
    end
  end
end
