# require_relative './jeff_controller.rb'

# module ActionDispatch
#   module Routing
#     class RouteSet
#       class Dispatcher
#         def controller(params, default_controller=true)
#           if params && params.key?(:controller)
#             controller_param = params[:controller]
#             controller_reference(controller_param)
#           end
#         rescue NameError => e
#           raise ActionController::RoutingError, e.message, e.backtrace if default_controller
#         end

#         def controller_reference(controller_param)
#           begin
#             const_name = @controller_class_names[controller_param] ||= "#{controller_param.camelize}Controller"
#             ActiveSupport::Dependencies.constantize(const_name)
#           rescue NameError => e
#             Kernel.class_eval("class ::#{const_name} < ApplicationController; end")
#             ActiveSupport::Dependencies.constantize("::#{const_name}")
#           end
#         end
#       end
#     end
#   end
# end
