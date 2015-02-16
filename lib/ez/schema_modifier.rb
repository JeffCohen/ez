module EZ

  # The SchemaModifier class receives a DomainModeler specification
  # and applies any necessary db schema changes.
  class SchemaModifier

    attr_reader :db, :spec, :dry_run

    def initialize(model_spec, silent = false, dry_run = false)
      @silent = silent
      @dry_run = dry_run
      @spec = model_spec
      connect_to_database
    end

    def self.migrate(model_spec, silent = false, dry_run = false)
      self.new(model_spec, silent, dry_run).migrate
    end

    def migrate
      @changed = false

      if @dry_run
        puts "Previewing... no changes will actually take place..."
        puts
      end

      add_missing_schema
      remove_dead_schema

      if @changed
        puts "\n(No changes were actually made)" if @dry_run
      else
          puts "All tables are up-to-date."
        if @dry_run
          puts "\nNo changes would be made."
        end
      end

      return @changed

      rescue => e
        puts e.message
        puts e.backtrace.first
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
      db_columns = db.columns(table_name)

      columns.each do |col_name, data|
        col_type = data[:type].to_sym
        col_default = data[:default]
        db_col = !assume_missing && (db_columns.detect { |dbc| dbc.name == col_name })

        if !db_col
          if !assume_missing
            display_change "Adding new column '#{col_name}' as #{col_type} for model #{model_name}"
          end
          opts = { default: col_default }
          opts[:limit] = data[:limit] if data[:limit]
          db.add_column(table_name, col_name.to_sym, col_type.to_sym, opts)  unless @dry_run
          if data[:index]
            display_change "  (adding database index for '#{col_name}')"
            db.add_index table_name, col_name.to_sym unless @dry_run
          end
        else
          if db_col.type != col_type
            display_change "Changing column type for #{col_name} to #{col_type} for model #{model_name}"
          end

          # puts "#{table_name} #{col_name}: #{db_col.default} and #{col_default}"
          if db_col.default != col_default
            displayable_value = col_default
            displayable_value = "NULL" if col_default.nil?
            display_change "Applying new default value #{displayable_value} for #{col_name} for model #{model_name}"
          end

          if (db_col.type != col_type) || (db_col.default != col_default)
              opts = { default: col_default }
              opts[:limit] = data[:limit] if data[:limit]
              db.change_column(table_name, col_name.to_sym, col_type.to_sym, opts)  unless @dry_run
          end
        end
      end
    end

    def add_model(model_name, columns)
      table_name = model_name.tableize
      display_change "Defining new table for model '#{model_name}'."
      db.create_table table_name  unless @dry_run
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
          # puts spec_columns.inspect
          dead_columns = db_columns - spec_columns


          if dead_columns.any?
            dead_columns.each do |dead_column_name|
              display_change "Removing unused column '#{dead_column_name}' from model '#{model_name}'"
            end
            db.remove_columns(table_name, *dead_columns)  unless @dry_run
          end
        end
      end
    end

    def update_schema_version
      # db.initialize_schema_migrations_table
      # db.assume_migrated_upto_version(Time.now.utc.strftime("%Y%m%d%H%M%S"))
    end

    def remove_dead_tables
      tables_we_need = @spec.keys.map { |model| model.tableize }
      dead_tables = tables - tables_we_need

      dead_tables.each do |table_name|
        model_name = table_name.classify
        display_change "Dropping table #{table_name}"
        db.drop_table(table_name) unless @dry_run
        begin
          filename = "app/models/#{model_name.underscore}.rb"
          code = IO.read(filename)
          is_empty = IO.read(filename) =~ /\s*class #{model_name} < ActiveRecord::Base\s+end\s*/

          if is_empty
            display_change "Deleting file #{filename}"
            File.unlink(filename) unless @dry_run
          end
        rescue => e
          display_change "Could not delete old model #{model_name.underscore}.rb."
        end
      end
    end

    def connect_to_database
      ActiveRecord::Base.establish_connection
      @db = ActiveRecord::Base.connection
    end

  end
end
