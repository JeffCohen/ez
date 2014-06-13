require_relative 'schema_modifier'

module EZ
  class DomainModeler

    def initialize
      load_model_specs
    end

    def self.update_tables
      self.new.update_tables
    end

    def update_tables
      SchemaModifier.migrate(@spec)
    end

    def load_model_specs
      @spec = YAML.load_file('db/models.yml')
      @spec ||= {}

      @spec.each do |model, columns|
        @spec[model] = []
        columns.each do |column|
          if column.is_a?(String) || column.is_a?(Symbol)
            if column.to_s =~ /_id$/
              @spec[model] << { column.to_s => 'integer' }
            elsif column.to_s =~ /_at$/
              @spec[model] << { column.to_s => 'datetime' }
            elsif column.to_s =~ /_on$/
              @spec[model] << { column.to_s => 'date' }
            else
              @spec[model] << { column.to_s => 'string' }
            end
          elsif column.is_a?(Hash) && column.keys.count == 1
            @spec[model] << { column.keys.first.to_s => column.values.first.to_s }
          else
            raise "Bad syntax around `#{column.inspect}`"
          end
        end
      end
    end

  end

end
