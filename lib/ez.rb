require "ez/version"
require 'ez/dispatcher.rb'
require 'ez/mapper.rb'
require 'ez/apis.rb'
require 'ez/domain_modeler.rb'
require 'ez/controller.rb'
require 'ez/model.rb'

module EZ
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/ez_tasks.rake"
    end

    initializer "ez" do
      module ::Hirb
        # A Formatter object formats an output object (using Formatter.format_output) into a string based on the views defined
        # for its class and/or ancestry.
        class Formatter
          def determine_output_class(output)
            if output.respond_to?(:to_a) && to_a_classes.any? {|e| output.is_a?(e) }
              Array(output)[0].class
            else
              if output.is_a?(ActiveRecord::Base)
                Hash
              else
                output.class
              end
            end
          end
        end
      end
    end
  end
end
