require 'labici/magento'
require 'labici/shopify'
require 'labici/abstract_migrator'
require 'fileutils'

module LaBici
  class ProductMigrator < AbstractMigrator
    MAG_TYPE_CATEGORY_ID = 24
    MAG_BRAND_CATEGORY_ID = 23
    MAG_TYPE_CATEGORY_IDS = [
      25,
      21,
      24,
      22,
      19]
    IGNORE_CATEGORY_IDS = [
      1,
      2,
      489,
      107,
      39,
      488,
      20,
      18,
      17,
      23]

    def self.tagify_categories(categories)
      categories.
        reject { |c| IGNORE_CATEGORY_IDS.include?(c[:id]) }.
        map { |c| c[:name] }.
        uniq
    end

    def banner
      'Migrating products from Magento to Shopify'
    end

    def magento_products
      raise NotImplementedError
    end

    def magento_to_shopify_attrs(mp)
      cats = magento.all_product_categories(mp[:id]).all
      tags = self.class.tagify_categories(cats)

      product_type_category = cats.detect { |c| MAG_TYPE_CATEGORY_IDS.include?(c[:id]) }

      product_type = if product_type_category
        product_type_category[:name]
      end

      product_brand_category = cats.detect { |c| c[:parent_id] == MAG_BRAND_CATEGORY_ID }

      product_vendor = mp[:vendor] || (
        product_brand_category ? product_brand_category[:name] : nil
      )

      { title: mp[:title],
        body_html: mp[:description],
        price: mp[:price] && mp[:price].to_f,
        sku: mp[:sku],
        tags: tags,
        vendor: product_vendor,
        images: gallery_to_images(mp),
        product_type: product_type }
    end

    def gallery_to_images(magento_product)
      gallery_items = magento.product_media_gallery(magento_product[:id]).all

      gallery_items.map { |item| {
        file: File.join(root, 'data/magento_media/catalog/product', item[:image_path]),
        position: item[:position]
      } }
    end

    def perform
      magento_products.each do |mp|
        next if has_migrated_id?(mp[:id])

        mp[:title] = mp[:title].strip

        notify_start_task(mp[:title])

        shopify_attrs   = magento_to_shopify_attrs(mp)
        shopify_product = shopify.create_product(shopify_attrs)

        if shopify_product.valid?
          remember_ids(mp[:id], shopify_product.id)
          notify_success
        else
          notify_failure
          ap shopify_attrs
          ap shopify_product.errors
          break
        end
      end
    end
  end
end
