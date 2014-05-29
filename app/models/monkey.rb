module ActiveRecord
  class Base
    def human_identifier
      if self.respond_to? :name
        self.name
      else
        self.id
      end
    end
  end
end