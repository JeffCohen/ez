module EZ
  class SchemaModifier

    attr_reader :db, :spec

    def initialize(model_spec)
      @spec = model_spec
      connect_to_database
    end

    def self.migrate(model_spec)
      self.new(model_spec).migrate
    end

    def migrate
      @changed = false

      add_missing_schema
      remove_dead_schema

      if @changed
        update_schema_version
      else
        puts "Everything is up-to-date."
      end

      return @changed

      rescue => e
        puts e.message
        false
    end


    def tables
      @tables ||= (db.tables - ['schema_migrations'])
    end

    def missing_model?(model_name)
      missing_table?(model_name.tableize)
    end

    def missing_table?(name)
      tables.index(name).nil?
    end

    def add_missing_schema
      @spec.each do |model_name, columns|
        if missing_model?(model_name)
          add_model(model_name, columns)
        else
          add_missing_columns(model_name, columns)
        end
      end
    end

    def display_change(message)
      puts message
      @changed = true
    end

    def add_missing_columns(model_name, columns, assume_missing = false)
      table_name = model_name.tableize
      columns.each do |column|
        col_name = column.keys.first
        col_type = column[col_name]
        if !assume_missing && db.column_exists?(table_name, col_name.to_sym)
          unless db.column_exists?(table_name, col_name.to_sym, col_type.to_sym)
            display_change "Changing column type for '#{col_name}' to #{col_type}"
            db.change_column(table_name, col_name.to_sym, col_type.to_sym)
            if col_name.to_s =~ /_id$/
              display_change "  (adding foreign_key index for '#{col_name}')"
              db.add_index table_name, col_name.to_sym
            end
          end
        else
          if !assume_missing
            display_change "Adding new column '#{col_name}' as #{col_type} for model #{model_name}"
          end
          options = {}
          options[:default] = false if col_type.to_sym == :boolean
          db.add_column(table_name, col_name.to_sym, col_type.to_sym, options)
          if col_name.to_s =~ /_id$/
            display_change "  (adding foreign_key index for '#{col_name}')"
            db.add_index table_name, col_name.to_sym
          end
        end
      end
    end

    def add_model(model_name, columns)
      table_name = model_name.tableize
      display_change "Defining new table for model '#{model_name}'."
      db.create_table table_name
      add_missing_columns model_name, columns, true
      #     columns.each do |column|
      #       name = column.keys.first
      #       col_type = column[name]
      #       options = {}
      #       options[:default] = false if col_type.to_sym == :boolean
      #       t.send(col_type, name, options)
      #     end
      #     # t.timestamps
      #   end
      # end
      filename = "app/models/#{model_name.underscore}.rb"
      unless Rails.env.production? || File.exists?(filename)
        display_change "Creating new model file: #{filename}"
        File.open(filename, "w") do |f|
          f.puts "class #{model_name} < ActiveRecord::Base"
          f.puts "end"
        end
      end
    end

    def remove_dead_schema
      remove_dead_tables
      remove_dead_columns
    end

    def remove_dead_columns
      tables.each do |table_name|
        model_name = table_name.classify.to_s
        if @spec.has_key?(model_name)
          columns = db.columns(table_name).map { |column| column.name.to_sym } - [:id, :created_at, :updated_at]
          spec_columns = @spec[model_name].map do |column_entry|
            column_entry.is_a?(Hash) ? column_entry.keys.first.to_sym : column_entry.to_sym
          end
          dead_columns = columns - spec_columns
          if dead_columns.any?
            dead_columns.each do |dead_column_name|
              display_change "Removing unused column '#{dead_column_name}' from model '#{model_name}'"
            end
            db.remove_columns(table_name, *dead_columns)
          end
        end
      end
    end

    def update_schema_version
      db.initialize_schema_migrations_table
      db.assume_migrated_upto_version(Time.now.utc.strftime("%Y%m%d%H%M%S"))
    end

    def remove_dead_tables
      tables_we_need = @spec.keys.map { |model| model.tableize }
      dead_tables = tables - tables_we_need

      dead_tables.each do |table_name|
        model_name = table_name.classify
        display_change "Dropping model #{model_name}"
        db.drop_table(table_name)
        display_change "Deleting file #{model_name.underscore}.rb"
        File.unlink "app/models/#{model_name.underscore}.rb" rescue nil
      end
    end

    def silence_migration_output
      ActiveRecord::Migration.verbose = false
    end

    def connect_to_database
      ActiveRecord::Base.establish_connection
      @db = ActiveRecord::Base.connection
    end

  end
end
