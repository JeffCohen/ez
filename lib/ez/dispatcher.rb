module ActionDispatch
  module Routing
    class RouteSet
      class Dispatcher
        def controller(params, default_controller=true)
          Rails.logger.debug "YES"
          if params && params.key?(:controller)
            controller_param = params[:controller]
            controller_reference(controller_param)
          end
        rescue NameError => e
          Rails.logger.debug "Whoa"
          raise ActionController::RoutingError, e.message, e.backtrace if default_controller
        end

        def controller_reference(controller_param)
          const_name = @controller_class_names[controller_param] ||= "#{controller_param.camelize}Controller"
          ActiveSupport::Dependencies.constantize(const_name)
        rescue NameError => e
          Rails.logger.debug "Fixing it!"
          ActiveSupport::Dependencies.constantize("JeffController")
        end

      end
    end
  end
end
