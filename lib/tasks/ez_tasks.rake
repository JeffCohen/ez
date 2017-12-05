namespace :db do

  namespace :migrate do

    desc "Preview table updates"
    task :preview => :environment do
      if File.exists?('db/models.yml')
        EZ::DomainModeler.update_tables(false, true)
      else
        puts "Nothing to preview."
      end
    end

  end
end

namespace :ez do

  desc "Generate models.yml if it doesn't exist yet."
  task :generate_yml do
    EZ::DomainModeler.generate_models_yml
  end

  desc "Erases all data, and builds all table schema from scratch."
  task :reset_tables => ['db:drop', :tables] do
  end

  desc "Attempts to update the database schema and model files with minimal data loss."
  task :tables => [:environment] do
    emit_help_page unless File.exists?('db/models.yml')
    EZ::DomainModeler.automigrate
  end

  def emit_help_page
    puts "You can now edit the db/models.yml file to describe your table schema."
  end
end
