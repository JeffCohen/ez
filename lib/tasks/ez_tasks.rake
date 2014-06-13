namespace :ez do

  desc "Generate models.yml if it doesn't exist yet."
  task :generate_yml do
    filename = "db/models.yml"
    unless File.exist?(filename)
      File.open(filename, "w") do |f|
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

  desc "Erases all data, and builds all table schema from scratch."
  task :reset_tables => ['db:drop', :tables] do
  end


  desc "Attempts to update the database schema and model files with minimal data loss."
  task :tables => ['db:migrate'] do
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
