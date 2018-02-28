require 'fileutils'

module EZ

  class RailsUpdater

    METHODS = %w(index show destroy new create edit update)
    VIEWS = %w(index show destroy new create edit update)

    def self.update!
      return unless Rails.env.development?

      EZ::DomainModeler.tables.each do |table|
        create_controller(table) if EZ::Config.controllers?
        create_view_folder(table) if EZ::Config.views?
        create_routes(table) if EZ::Config.routes?
      end
    end

    def self.create_routes(table)
      return unless Rails.env.development?

      filename = File.join(Rails.root, 'config', 'routes.rb')
      line = "  resources :#{table}"
      routes = File.read(filename)
      if !routes.index(line)
        routes.sub!(/^\s*\# For details on the DSL available.+$/,'')
        routes.sub!(/^(.+routes.draw do\s*)$/, '\1' + "\n#{line}\n")
        File.open(filename, "wb") { |file| file.write(routes) }
      end
    end

    def self.create_controller(controller)
      return unless Rails.env.development?

      filename = File.join(Rails.root, 'app', 'controllers', "#{controller}_controller.rb")
      if !File.exist?(filename)
        File.open(filename, "w:utf-8") do |file|
          file.puts "class #{"#{controller}_controller".classify} < ApplicationController"
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
      return unless Rails.env.development?

      full_path = File.join(Rails.root, 'app', 'views', folder)
      FileUtils.mkdir_p(full_path)
      VIEWS.each do |view|
        filename = File.join(full_path, "#{view}.html.erb")
        if !File.exist?(filename)
          File.open(filename, "w:utf-8") do |file|
            file.puts "<h1>This is a placeholder page.</h1>"
            file.puts "<p>To modify this page, edit the template at <code>app/views/#{folder}/#{view}.html.erb</code></p>"
          end
        end
      end
    end

  end

end
