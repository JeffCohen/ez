module ActionController
  class Base

    if Rails.env.development?

      # before_action :ez_update_tables

      def ez_update_tables
        Rails.cache.fetch('ez-generate-yml') do
          EZ::DomainModeler.generate_models_yml
        end
        EZ::DomainModeler.update_tables(true)
        EZ::DomainModeler.dump_schema
      end

    end

  end
end
