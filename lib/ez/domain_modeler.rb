require_relative 'schema_modifier'

module EZ
  # The DomainModeler class implements the db/models.yml file syntax
  # and provides a hash of the domain model specification.

  class DomainModeler

    # Valid formats for default values
    DEFAULT_VALUE_REGEXES = [/\s*\((.+)?\)/, /\s+(.+)?\s*/, /,\s*default:\s*(.+)?\s*/]

    def self.models
      tables = ActiveRecord::Base.connection.tables - ['schema_migrations']
      tables.map { |t| t.classify }
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

    def self.generate_models_yml
      filename = Rails.root + "db/models.yml"
      unless File.exist?(filename)
        File.open(filename, "w") do |f|
          f.puts <<-EOS
  # Example table for a typical Book model.
  #
  Book
    title: string
    price: integer
    author: string
    summary: text
    hardcover: boolean
  #
  # Indent consistently!  Follow the above syntax exactly.
  # Typical column choices are: string, text, integer, boolean, date, and datetime.
  #
  # Default column values can be specified like this:
  #    price: integer(0)
  #
  # Have fun!

  EOS
        end
      end
    end

    def self.update_tables(silent = false)
      self.new.update_tables(silent)
    end

    def update_tables(silent = false)
      return false unless @ok

      SchemaModifier.migrate(@spec, silent)
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
          'string'
        end
      end

      default_column_value = nil
      DEFAULT_VALUE_REGEXES.each { |r| default_column_value = $1 if column_type.sub!(r, '') }
      default_column_value = default_column_value.to_i if column_type == 'integer'
      default_column_value = default_column_value.to_f if column_type == 'float'

      if column_type == 'boolean'
        default_column_value = default_column_value.present? && default_column_value.downcase.strip == 'true'
      end

      @spec[model][column_name] = { type: column_type, default: default_column_value}
      @spec[model][column_name][:index] = true if column_name =~ /_id$/
    end
  end

end
