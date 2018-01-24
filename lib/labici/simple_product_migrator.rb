require 'labici/migrator'

module LaBici
  class SimpleProductMigrator < Migrator
    MEMO_FILENAME = 'migrated_simple_product_ids.txt'.freeze

    def magento_products
      magento.products(simple_with_options: true)
    end

    def magento_to_shopify_attrs(mp)
      attrs = super

      options = magento.product_options(mp[:id]).all

      option_types = options.map { |row| row[:option_name] }.uniq

      option_types.

      ap options
    end

    def memory_filename
      @memory_filename ||= File.join(root, "data/#{MEMO_FILENAME}")
    end
  end
end
