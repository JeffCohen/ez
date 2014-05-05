class ActiveRecord::Base

  def self.magic_associations
    x = self.column_names.select { |n| n.ends_with? '_id' }

    x.each do |fk|
      assoc_name = fk[0, fk.length - 3]
      belongs_to assoc_name.to_sym
      assoc_name.classify.constantize.send(:has_many, self.name.underscore.pluralize.to_sym, dependent: :destroy)
    end
  end

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

end
