namespace :ez do

  desc "Generate models.yml if it doesn't exist yet."
  task :generate_yml do
    filename = "db/models.yml"
    unless File.exist?(filename)
      File.open(filename, "w") do |f|
        f.puts <<-EOS
# Example table for a typical Book model.
#
# Book
#   title: string
#   author_id: integer
#   price: integer
#   summary: text
#   hardcover: boolean
#
# Indent consistently!  Follow the above syntax exactly.
# Typical column choices are: string, text, integer, boolean, date, time, and datetime.
#
#
# Specifying Default Values
# ----------------------------------------------------
# Default column values can be specified like this:
#    price: integer(0)
#
# If not specified, Boolean columns always default to false.
#
#
# Convention-Based Defaults:
# ----------------------------------------------------
# You can omit the column type if it's a string, or if it's obviously an integer column:
#
#
# Book
#   title
#   author_id
#   price: integer
#   summary: text
#   hardcover: boolean
#
# Complete details are in the README file online.
#
# Have fun!

EOS
      end
    end
  end

  desc "Erases all data, and builds all table schema from scratch."
  task :reset_tables => ['db:drop', :tables] do
  end


  desc "Attempts to update the database schema and model files with minimal data loss."
  task :tables => [:environment] do
    if File.exists?('db/models.yml')
      if EZ::DomainModeler.update_tables
        Rake::Task["db:schema:dump"].invoke unless Rails.env.production?
      end
    else
      Rake::Task["ez:generate_yml"].invoke
      emit_help_page
    end
  end

  def emit_help_page
    puts "You can now edit the db/models.yml file to describe your table schema."
  end
end
