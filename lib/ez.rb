require "ez/version"
require 'ez/domain_modeler'
require 'ez/model'
require 'ez/config'
require 'awesome_print' if (Rails.env.development? || Rails.env.test?)
require 'hirb' if (Rails.env.development? || Rails.env.test?)

module EZ

  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/ez_tasks.rake"
      Rake::Task["db:migrate"].enhance ["ez:tables"]
    end

    console do |app|
      AwesomePrint.irb! if (Rails.env.development? || Rails.env.test?)

      Hirb.enable(pager: false) if (Rails.env.development? || Rails.env.test?) && defined?(Hirb)

      I18n.enforce_available_locales = false

      models = EZ::DomainModeler.models
      puts
      puts "Rails Console"
      puts "-" * 50
      puts "* Type 'exit' (or press CTRL-D) when you're done."
      puts "* Press Ctrl-C if things seem to get stuck."
      puts "* Use the up/down arrows to repeat commands."
      puts
      if models.any?
        puts "Models: #{models.to_sentence}"
        puts
        puts "Use this console to create, read, update, and delete rows from the database."
        puts "Or simply type the name of a model to see what columns it has."
      end
      puts
    end

    initializer "ez" do

      if Rails::VERSION::MAJOR < 5
        ActionDispatch::Reloader.to_prepare do
          DomainModeler.automigrate
        end
      else
        ActiveSupport::Reloader.to_prepare do
          DomainModeler.automigrate
        end
      end

      if (Rails.env.development? || Rails.env.test?)

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
end
