require_relative 'schema_modifier'
require_relative 'rails_updater'

module EZ

  COLUMN_TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

  # The DomainModeler class implements the db/models.yml file syntax
  # and provides a hash of the domain model specification.

  class DomainModeler

    # Valid formats for default values
    DEFAULT_VALUE_REGEXES = [/\s*\((.+)?\)/, /\s+(.+)?\s*/, /,\s*default:\s*(.+)?\s*/]

    def self.tables
      tables = ActiveRecord::Base.connection.data_sources - ['schema_migrations', 'ar_internal_metadata']
    end

    def self.models
      tables.map { |t| t.classify }
    end

    def self.should_migrate?(models_yml = nil)
      models_yml ||= File.join(Rails.root, 'db', 'models.yml')
      return false unless File.exist?(models_yml)

      schema_rb = File.join(Rails.root, 'db', 'schema.rb')
      sqlite_db = File.join(Rails.root, 'db', "#{Rails.env}.sqlite3")
      !(Rails.env.development? || Rails.env.test?) ||
        (!File.exist?(schema_rb) || (File.mtime(schema_rb) < File.mtime(models_yml))) ||
          (!File.exist?(sqlite_db) || (File.mtime(sqlite_db) < File.mtime(models_yml)))
    end

    def self.automigrate
      return unless EZ::Config.models?

      begin
        models_yml = File.join(Rails.root, 'db', 'models.yml')
        EZ::DomainModeler.generate_models_yml unless File.exist?(models_yml)

        if should_migrate?(models_yml)
          old_level = ActiveRecord::Base.logger.level

          ActiveRecord::Base.logger.level = Logger::WARN
          EZ::DomainModeler.update_tables
          dump_schema if (Rails.env.development? || Rails.env.test?)

          ActiveRecord::Base.logger.level = old_level
          EZ::RailsUpdater.update! if Rails.env.development?
        end
      rescue => e
        puts "Exception: #{e}"
      end
    end

    # Get the domain model as a hash
    attr_reader :spec

    def initialize
      @ok = false
      begin
        load_model_specs
        @ok = true
      rescue => e
        puts e
      end
    end

    def self.dump_schema
      require "active_record/schema_dumper"
      File.open(File.join(Rails.root, 'db/schema.rb'), "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end

    def self.generate_models_yml
      return unless Rails.env.development?

      filename = Rails.root + "db/models.yml"
      unless File.exist?(filename)
        File.open(filename, "w") do |f|
          f.puts <<-EOS
# Example:
#
# Book
#   title: text
#   author_id: integer
#   summary: text
#   price: integer
#   hardcover: boolean
#
#
# Indent consistently!  Follow the above syntax exactly.
#
#
#
# Column choices are: text, integer, boolean, datetime, and float.
#
#
# Default values can be specified like this:
#
#    price: integer(0)
#
# If not specified, Boolean columns always default to false.
#
# You can omit the column type if it's a text column or obviously an integer column:
#
# Book
#   title
#   author_id
#   summary
#   price: integer
#   hardcover: boolean
#
# Complete details are in the README file online.
#
# Have fun!
  EOS
        end
      end
    end

    def self.update_tables(silent = false, dry_run = false)
      self.new.update_tables(silent, dry_run)
    end

    def update_tables(silent = false, dry_run = false)
      return false unless @ok

      SchemaModifier.migrate(@spec, silent, dry_run)
      return true

      rescue => e
        puts e.message unless silent
        puts e.backtrace.first unless silent
        @ok = false
        return false
    end

    def load_model_specs_from_string(s)

      # Ignore comments
      s.gsub!(/#.*$/,'')

      # Append missing colons
      s.gsub!(/^((\s|\-)*\w[^\:]+?)$/, '\1:')

      # Replace ", default:" syntax so YAML doesn't try to parse it
      s.gsub!(/,?\s*(default)?:?\s(\S)\s*$/, '(\2)')

      # For backward compatibility with old array syntax
      s.gsub!(/^(\s*)\-\s*/, '\1')

      @spec = YAML.load(s)
      parse_model_spec

      # puts "@spec:"
      # puts @spec.inspect
      # puts "-" * 10
    end

    def load_model_specs(filename = "db/models.yml")
      load_model_specs_from_string(IO.read(filename))
    end

    def parse_model_spec
      @spec ||= {}
      @spec.each do |model, columns|

        msg = nil

        if !columns.is_a?(Hash)
          msg = "Could not understand models.yml while parsing model '#{model}'."
        end

        if model !~ /^[A-Z]/ || model =~ /\s/
          msg = "Could not understand models.yml while parsing model '#{model}'."
          msg <<  " Models must begin with an uppercase letter and cannot contain spaces."
        end

        raise msg if msg

        if EZ::Config.timestamps?
          columns['created_at'] = 'datetime'
          columns['updated_at'] = 'datetime'
        end

        columns.each do |column_name, column_type|
          interpret_column_spec column_name, column_type, model
        end
      end

    end

    def interpret_column_spec(column_name, column_type, model)
      column_type ||= begin
        if column_name =~ /_id|_count$/
          'integer'
        elsif column_name =~ /_at$/
          'datetime'
        elsif column_name =~ /_on$/
          'date'
        elsif column_name =~ /\?$/
          'boolean'
        else
          'text'
        end
      end

      default_column_value = nil
      DEFAULT_VALUE_REGEXES.each { |r| default_column_value = $1 if column_type.sub!(r, '') }
      default_column_value = default_column_value.to_i if default_column_value.present? && column_type == 'integer'
      default_column_value = default_column_value.to_f if default_column_value.present? && column_type == 'float'

      if column_type == 'boolean'
        default_column_value = default_column_value.present? && default_column_value.in?(EZ::COLUMN_TRUE_VALUES)
      end

      @spec[model][column_name] = { type: column_type, default: default_column_value}
      @spec[model][column_name][:limit] = 1024 if column_type == 'binary'
      @spec[model][column_name][:index] = true if column_name =~ /_id$/
    end
  end

end
