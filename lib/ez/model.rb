class ActiveRecord::Base

  def inspect
    "#<#{self.class.name} #{attributes}>"
  end

  def self.read(args)
    if args.is_a?(Integer)
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
