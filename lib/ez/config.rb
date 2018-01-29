module EZ

  class Config

    DEFAULTS = { "models" => true,
                 "restful_routes" => false,
                 "controllers" => false,
                 "views" => false,
                 "timestamps" => true
               }

    def self.to_h
      configuration
    end

    def self.save!
      File.open(filename,"w") do |file|
       file.write @config.to_yaml.sub(/^\-+$/,'')
      end
      @config
    end

    def self.filename
      @filename = begin
        n = File.join(Rails.root, '.ez')
        if File.exist?(n)
          n
        else
          File.expand_path('~/.ez')
        end
      end
    end

    def self.configuration
      @config ||= begin
        if File.exist?(filename)
          DEFAULTS.merge YAML.load_file(filename)
        else
          DEFAULTS
        end
      end
    end

    def self.timestamps?
      configuration["timestamps"]
    end

    def self.routes?
      configuration["restful_routes"]
    end

    def self.models?
      configuration["models"]
    end

    def self.controllers?
      configuration["controllers"]
    end

    def self.views?
      configuration["views"]
    end

  end

end
