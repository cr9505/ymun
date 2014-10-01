class Hash
  def diff(other)
    (self.keys + other.keys).uniq.inject({}) do |memo, key|
      unless self[key] == other[key]
        if self[key].kind_of?(Hash) &&  other[key].kind_of?(Hash)
          memo[key] = self[key].diff(other[key])
        else
          memo[key] = [self[key], other[key]] 
        end
      end
      memo
    end
  end
end

module ActionDispatch
  module Routing
    class RoutesProxy
      def new_admin_user_session_path(opts={})
        new_user_session_path(opts)
      end

      def new_advisor_session_path(opts={})
        new_user_session_path(opts)
      end

      def new_delegate_session_path(opts={})
        new_user_session_path(opts)
      end

      def destroy_admin_user_session_path(opts={})
        destroy_user_session_path(opts)
      end

      def destroy_advisor_session_path(opts={})
        new_user_session_path(opts)
      end

      def destroy_delegate_session_path(opts={})
        new_user_session_path(opts)
      end
    end
  end
end
