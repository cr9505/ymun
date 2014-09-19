module CommitteeParser
  class YMGE
    def self.parse(worksheets)
      ws = worksheets[0]
      delegation_hash = {}
      for row in 2..ws.num_rows
        delegation = ws[row, 1]
        delegation_hash[delegation] ||= {}
        for col in 2..ws.num_cols
          committee_and_position = ws[row, col]
          committee, position = committee_and_position.split(':')
          committee.strip!
          position.strip!
          delegation_hash[delegation][committee] ||= []
          delegation_hash[delegation][committee] << position
        end
      end
      delegation_hash
    end
  end
end