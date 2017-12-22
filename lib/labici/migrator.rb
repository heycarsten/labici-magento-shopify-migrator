require 'labici/magento'
require 'labici/shopify'

module LaBici
  class Migrator
    attr_reader :magento, :shopify

    MAG_TYPE_CATEGORY_ID = 24

    def self.run!
      new.run!
    end

    def initialize
      @magento = Magento.new
      @shopify = Shopify.new
    end

    def run!
      mp = magento.products(manufacturer_value: 'ASSOS').first

      product_type_category = magento.product_categories(
        entity_id: mp[:id],
        parent_id: MAG_TYPE_CATEGORY_ID
      ).first

      product_type = if product_type_category
        product_type_category[:name]
      end

      image_file = if mp[:image_path]
        root = File.expand_path('../../..', __FILE__)
        File.join(root, 'data/magento_media/catalog/product', mp[:image_path])
      end

      shopify_product = shopify.create_product(
        title: mp[:title],
        body_html: mp[:description],
        price: mp[:price] && mp[:price].to_f,
        sku: mp[:sku],
        vendor: mp[:vendor],
        image_file: image_file,
        product_type: product_type
      )
    end
  end
end
