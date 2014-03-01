module ActionDispatch
  module Routing
    class Mapper
      class Mapping

        def route_uses_slash_and_no_hash?
          @options[:to].is_a?(String) &&
            @options[:to].index('#').nil? &&
            @options[:to].index('/')
        end

        def to
          if route_uses_slash_and_no_hash?
            @options[:to].sub('/','#')
          else
            @options[:to]
          end
        end
      end
    end
  end
end
