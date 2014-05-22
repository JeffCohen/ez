namespace :ez do

  desc "Generate models.yml if it doesn't exist yet."
  task :generate_yml do
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

  desc "Reset the database schema and data from scratch."
  task :reset_tables => ['db:drop', :tables] do
  end


  desc "Attempts to update the database schema and model files with minimal data loss."
  task :tables => :environment do
    if File.exists?('db/models.yml')
      EZ::DomainModeler.update_tables
      Rake::Task["db:schema:dump"].invoke unless Rails.env.production?
    else
      emit_help_page
      Rake::Task["ez:generate_yml"].invoke
    end
  end

  def emit_help_page
    puts "To get started, edit the db/models.yml file to describe your table schema."

  end
end
