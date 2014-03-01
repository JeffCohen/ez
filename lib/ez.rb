require "ez/version"
require 'ez/dispatcher.rb'
require 'ez/mapper.rb'
require 'ez/apis.rb'

module Ez
  class MyRailtie < Rails::Railtie
    rake_tasks do
      load "tasks/ez_tasks.rake"
    end
  end
end
