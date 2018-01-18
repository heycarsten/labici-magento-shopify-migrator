require 'labici/magento'
require 'labici/shopify'
require 'fileutils'

module LaBici
  class Migrator
    attr_reader :magento, :shopify

    MAG_TYPE_CATEGORY_ID = 24
    MAG_BRAND_CATEGORY_ID = 23
    MEMO_FILENAME = 'migrated_product_ids.txt'

    MAG_TYPE_CATEGORY_IDS = [
      25,
      21,
      24,
      22,
      19
    ]

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
      23
    ]

    def self.run!
      new.run!
    end

    def initialize
      @magento = Magento.new
      @shopify = Shopify.new
      FileUtils.touch(memory_filename)
    end

    def self.tagify_categories(categories)
      categories.
        reject { |c| IGNORE_CATEGORY_IDS.include?(c[:id]) }.
        map { |c| c[:name] }.
        uniq
    end

    def run!
      puts "==== Migrating products from Magento to Shopify"

      magento.products(entity_type_id: 'configurable').each do |mp|
        next if has_migrated_product_id?(mp[:id])

        mp[:title] = mp[:title].strip

        print "---> #{mp[:title]} ... "

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

        gallery_items = magento.product_media_gallery(mp[:id]).all

        images = gallery_items.map { |item| {
          file: File.join(root, 'data/magento_media/catalog/product', item[:image_path]),
          position: item[:position]
        } }

        shopify_product = shopify.create_product(
          title: mp[:title],
          body_html: mp[:description],
          price: mp[:price] && mp[:price].to_f,
          sku: mp[:sku],
          tags: tags,
          vendor: product_vendor,
          images: images,
          product_type: product_type
        )

        if shopify_product
          remember_product_ids(mp[:id], shopify_product.id)
          puts '✅'
        else
          puts '💔'
          break
        end

        sleep 0.55
      end

      puts "---- Done!"
    end

    def root
      @root ||= File.expand_path('../../..', __FILE__)
    end

    def memory_filename
      @memory_filename ||= File.join(root, "data/#{MEMO_FILENAME}")
    end

    def has_migrated_product_id?(magento_product_id)
      found = false

      File.open(memory_filename, 'r') { |file|
        file.each_line { |line|
          next unless /\A#{magento_product_id},/ =~ line
          found = true
          break
        }
      }

      found
    end

    def remember_product_ids(magento_product_id, shopify_product_id)
      File.open(memory_filename, 'a+') { |file|
        file.puts("#{magento_product_id},#{shopify_product_id}")
      }
    end
  end
end
