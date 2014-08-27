module EZ
  class SchemaModifier

    attr_reader :db, :spec

    def initialize(model_spec, silent = false)
      @silent = silent
      @spec = model_spec
      connect_to_database
    end

    def self.migrate(model_spec, silent = false)
      self.new(model_spec, silent).migrate
    end

    def migrate
      @changed = false

      add_missing_schema
      remove_dead_schema

      if @changed
        update_schema_version
      else
        puts "All tables are up-to-date."
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
      puts message unless @silent
      @changed = true
    end

    def add_missing_columns(model_name, columns, assume_missing = false)
      table_name = model_name.tableize
      # {"nickname"=>{:type=>"string", :default=>nil}, "password_digest"=>{:type=>"string", :default=>nil}, "created_at"=>{:type=>"datetime", :default=>nil}, "updated_at"=>{:type=>"datetime", :default=>nil}, "course_id"=>{:type=>"integer", :default=>"(0)"}, "email"=>{:type=>"string", :default=>nil}, "full_name"=>{:type=>"string", :default=>nil}, "admin"=>{:type=>"boolean", :default=>true}}
      columns.each do |col_name, data|
        col_type = data[:type]
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
          db_columns = db.columns(table_name).map { |column| column.name.to_sym } - [:id, :created_at, :updated_at]
          spec_columns = @spec[model_name].keys.map(&:to_sym)
          dead_columns = db_columns - spec_columns

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
        display_change "Yo"
        display_change "Dropping model #{model_name}"
        db.drop_table(table_name)
        begin
          filename = "app/models/#{model_name.underscore}.rb"
          code = IO.read(filename)
          matched = IO.read(filename) =~ /\s*class #{model_name} < ActiveRecord::Base\s+end\s*/

          display_change "-" * 20
          display_change matched
          display_change code
          display_change "-" * 20

          if matched
            display_change "Deleting file #{filename}"
            File.unlink(filename)
          end
        rescue => e
          display_change "Could not delete old model #{model_name.underscore}.rb."
        end
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
