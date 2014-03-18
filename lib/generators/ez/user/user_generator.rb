require 'rails/generators/active_record'
require_relative './migration'
module Starter
  class UserGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Rails::Generators::ResourceHelpers
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
    remove_class_option :old_style_hash
    remove_class_option :force_plural
    remove_class_option :skip_namespace
    class_option :styled, :type => :boolean, :default => true, desc: 'Generates bootstrap-ready view templates'

    def generate_controller
      template 'user_controller.rb', "app/controllers/#{plural_name.underscore}_controller.rb"
      template 'sessions_controller.rb', "app/controllers/sessions_controller.rb"
    end

    def generate_model
      template 'model.rb', "app/models/#{singular_name.underscore}.rb"
    end

    def generate_migration
      return if options[:skip_model]
      migration_template "migration.rb", "db/migrate/create_#{table_name}.rb"
    end

    # def create_root_view_folder
    #   empty_directory File.join("app/views", controller_file_path)
    # end

    def copy_view_files
      available_views.each do |view|
        filename = view_filename_with_extensions(view)
        template filename, File.join("app/views", controller_file_path, File.basename(filename))
      end
    end


    def generate_routes
      route user_routes, "Routes"
    end

  protected

    def user_routes
      ["# Routes for sign up, user profile management, login, and logout:",
          "  get '/#{plural_name}/new' => '#{plural_name}#new'",
          "  get '/#{plural_name}/create' => '#{plural_name}#create'",
          "  get '/#{plural_name}/:#{singular_name}/show' => '#{plural_name}#show'",
          "  get '/#{plural_name}/:#{singular_name}/edit' => '#{plural_name}#edit'",
          "  get '/#{plural_name}/:#{singular_name}/update' => '#{plural_name}#update'",
          "  get '/#{plural_name}/:#{singular_name}/delete' => '#{plural_name}#destroy'",
          "  ",
          "  get '/login' => 'sessions#new'",
          "  get '/handle_login' => 'sessions#create'",
          "  get '/logout' => 'sessions#logout'"

        ].join("\n")
    end

    # Override of Rails::Generators::Actions
    def route(routing_code, title)
      log :route, title
      sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/

      in_root do
        inject_into_file 'config/routes.rb', "\n  #{routing_code}\n", { :after => sentinel, :verbose => false }
      end
    end

    def attributes_with_index
      attributes.select { |a| a.has_index? || (a.reference? && options[:indexes]) }
    end

    def available_views
      dry? ? %w(index new edit show _form) : %w(index new edit show)
    end

    def view_filename_with_extensions(name)
      filename = [name, :html, :erb].compact.join(".")
      folders = []
      folders << 'dried' if dry?
      folders << 'bootstrapped' if styled?
      filename = File.join(folders, filename) if folders.any?
      return filename
    end
  end
end
