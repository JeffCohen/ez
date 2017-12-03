require 'fileutils'

module EZ

  class RailsUpdater

    METHODS = %w(index show destroy new create edit update)
    VIEWS = %w(index show destroy new create edit update)

    def self.update!
      EZ::DomainModeler.tables.each do |table|
        create_controller(table) if EZ::Config.controllers?
        create_view_folder(table) if EZ::Config.views?
        create_routes(table) if EZ::Config.routes?
      end
    end

    def self.create_routes(table)
      filename = File.join(Rails.root, 'config', 'routes.rb')
      line = "  resources :#{table}"
      routes = File.read(filename)
      if !routes.index(line)
        line = "#{line}\n"
        routes.sub!(/^\s*\# For details on the DSL available.+$/,'')
        routes.sub!(/^(.+routes.draw do\s*)$/, '\1' + line)
        File.open(filename, "wb") { |file| file.write(routes) }
      end
    end

    def self.create_controller(controller)
      filename = File.join(Rails.root, 'app', 'controllers', "#{controller}_controller.rb")
      if !File.exist?(filename)
        File.open(filename, "w:utf-8") do |file|
          file.puts "class #{controller.classify} < ApplicationController"
          METHODS.each do |method|
            file.puts
            file.puts "  def #{method}"
            file.puts
            file.puts "  end"
          end
          file.puts
          file.puts "end"
        end
      end
    end

    def self.create_view_folder(folder)
      full_path = File.join(Rails.root, 'app', 'views', folder)
      FileUtils.mkdir_p(full_path)
      VIEWS.each do |view|
        File.open(File.join(full_path, "#{view}.html.erb"), "w:utf-8") do |file|
          file.puts "<h1>This is a temporary page.</h1>"
          file.puts "<p>To modify this page, edit the template at <code>app/views/#{folder}/#{file}.html.erb</p>"
        end
      end
    end

  end

end
