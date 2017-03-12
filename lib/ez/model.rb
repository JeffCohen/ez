class ActiveRecord::Base

  def inspect
    "#<#{self.class.name} #{attributes}>"
  end

  def self.read(args = nil)
    if args.nil?
      all
    elsif args.is_a?(Integer)
      find_by(id: args)
    elsif args.is_a?(String) && args.to_i > 0 && !args.index(' ')
      find_by(id: args)
    elsif args.is_a?(Hash) && args.keys.count == 1 && args.keys[0].to_sym == :id
      find_by(args)
    else
      where(args)
    end
  end

  def self.sample
    offset(rand(0...count)).first
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
