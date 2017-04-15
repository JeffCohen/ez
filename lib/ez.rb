require "ez/version"
require 'ez/domain_modeler.rb'
require 'ez/model.rb'

require 'hirb' if (Rails.env.development? || Rails.env.test?)

module EZ
  module Console
    def reload!(print = true)
      puts "Reloading code..." if print
      if Rails::VERSION::MAJOR < 5
        ActionDispatch::Reloader.cleanup!
        ActionDispatch::Reloader.prepare!
      else
        Rails.application.reloader.reload!
      end

      puts "Updating tables (if necessary) ..." if print
      old_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = Logger::WARN
      EZ::DomainModeler.generate_models_yml
      EZ::DomainModeler.update_tables
      EZ::DomainModeler.dump_schema
      puts "Models: #{EZ::DomainModeler.models.to_sentence}"
      ActiveRecord::Base.logger.level = old_level
      true
    end
  end
end

module EZ

  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/ez_tasks.rake"
      Rake::Task["db:migrate"].enhance ["ez:tables"]
    end

    console do |app|
      Rails::ConsoleMethods.send :prepend, EZ::Console
      Hirb.enable(pager: false) if (Rails.env.development? || Rails.env.test?) && defined?(Hirb)

      old_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = Logger::WARN
      EZ::DomainModeler.generate_models_yml
      EZ::DomainModeler.update_tables(true)
      ActiveRecord::Base.logger.level = old_level

      I18n.enforce_available_locales = false
      puts "Welcome to the Rails Console."
      puts "-" * 60
      puts
      models = EZ::DomainModeler.models
      if models.any?
        puts "Models: #{models.to_sentence}"
        puts
        puts "Use this console to add, update, and delete rows from the database."
        puts
        puts "HINTS:"
        puts "* Type 'exit' (or press Ctrl-D) to when you're done."
        puts "* Press Ctrl-C if things seem to get stuck."
        puts "* Use the up/down arrows to repeat commands."
        puts "* Type the name of a Model to see what columns it has." if models.any?
        puts
      end

    end

    initializer "ez" do

      # tables = ActiveRecord::Base.connection.data_sources - ['schema_migrations', 'ar_internal_metadata']
      # models.each { |m| m.constantize.magic_associations }
      # Rails.application.routes.draw do
      #   tables.each do |table_name|
      #     resources table_name.to_sym
      #   end
      # end

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
