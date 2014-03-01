require_relative 'db_modifier'

namespace :ez do

  desc "Reset the database scheme from scratch."
  task :reset_tables => ['db:drop', :tables] do
  end

  desc "Automatically update the database schema and model files."
  task :tables => :environment do
    if File.exists?('db/models.yml')
      db = DbModifier.new
      db.migrate
    else
      puts "To get started, edit the db/models.yml file to describe your table schema."
      File.open("db/models.yml", "w") do |f|
        f.puts <<-EOS
# Example table for a typical Book model.
#
# Book:
#   - title: string
#   - price: integer
#   - author: string
#   - summary: text
#   - hardcover: boolean
#
# Follow the syntax exactly (colons and spacing are important).
# Column type choices are: string, text, integer, and boolean.
# You can have as many models as you want in this file.
EOS
      end
    end
  end

end
