require 'labici/product_migrator'

module LaBici
  class ConfigurableProductMigrator < ProductMigrator
    def magento_products
      magento.products(entity_type_id: 'configurable')
    end
  end
end
