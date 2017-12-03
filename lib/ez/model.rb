class ActiveRecord::Base

  def self.sample(n = 1)
    n == 1 ? order("RANDOM()").first : order("RANDOM()").limit(n)
  end

  def self.none?
    self.count == 0
  end

  def self.to_ez
    s = self.name + ":\n"
    columns.each do |column|
      s <<  "  - #{column.name}: #{column.type}\n" unless column.name == 'id'
    end
    s
  end

  def self.dump_tables_to_ez
    (connection.data_sources - ['schema_migrations', 'ar_internal_metadata']).each do |table|
      puts table.classify.constantize.to_ez
    end
  end

end
