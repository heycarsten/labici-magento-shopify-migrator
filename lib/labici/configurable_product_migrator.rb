require 'labici/migrator'

module LaBici
  class ConfigurableProductMigrator < Migrator
    def magento_products
      magento.products(entity_type_id: 'configurable')
    end
  end
end
