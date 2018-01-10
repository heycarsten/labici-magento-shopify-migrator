require 'labici/magento'
require 'labici/shopify'
require 'fileutils'

module LaBici
  class Migrator
    attr_reader :magento, :shopify

    MAG_TYPE_CATEGORY_ID = 24
    MEMO_FILENAME = 'migrated_product_ids.txt'

    IGNORE_CATEGORY_IDS = [
      SHOP_BY_BRAND = 23
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
        map { |c| c[:path].gsub('shop-by-brand', 'brand').gsub('/', '-') }.
        uniq
    end

    def run!
      puts "---> Migrating products from Magento to Shopify"

      magento.products(entity_type_id: 'configurable').each do |mp|
        cats = magento.product_categories(entity_id: mp[:id])
        tags = self.class.tagify_categories(cats)

        puts "==="
        puts "PRODUCT: #{mp[:title].strip}"
        puts "ID     : #{mp[:id]}"

        if brand = cats.to_a.detect { |c| (c[:parent_id] == SHOP_BY_BRAND) && c[:level] == 3 }
          puts "BRAND  : #{brand[:name]}"
        end

        if mp[:image_path]
          puts "IMAGE  : #{mp[:image_path]}"
        end

        puts "TAGS   :"
        tags.each { |t| puts "  -> #{t}" }

        related_ids = magento.db[:catalog_product_relation].
          where(parent_id: mp[:id]).
          map(:child_id)

        if related_ids.any?
          puts "SUB-PRODUCTS:"

          magento.products(entity_ids: related_ids).each { |mpp|
            puts "  -> #{mpp[:title].strip} (#{mpp[:id]})"
          }
        end

        puts
      end

      # magento.products(manufacturer_value: 'ASSOS').each do |mp|
      #   next if has_migrated_product_id?(mp[:id])

      #   print "-- #{mp[:title]} ... "

      #   product_type_category = magento.product_categories(
      #     entity_id: mp[:id],
      #     parent_id: MAG_TYPE_CATEGORY_ID
      #   ).first

      #   product_type = if product_type_category
      #     product_type_category[:name]
      #   end

      #   image_file = if mp[:image_path]
      #     File.join(root, 'data/magento_media/catalog/product', mp[:image_path])
      #   end

      #   is_successful = shopify.create_product(
      #     title: mp[:title],
      #     body_html: mp[:description],
      #     price: mp[:price] && mp[:price].to_f,
      #     sku: mp[:sku],
      #     vendor: mp[:vendor],
      #     image_file: image_file,
      #     product_type: product_type
      #   )

      #   if is_successful
      #     remember_product_id(mp[:id])
      #     puts '✅'
      #   else
      #     puts '💔'
      #     break
      #   end

      #   sleep 1
      # end

      puts "---- Done!"
    end

    def root
      @root ||= File.expand_path('../../..', __FILE__)
    end

    def memory_filename
      @memory_filename ||= File.join(root, "data/#{MEMO_FILENAME}")
    end

    def has_migrated_product_id?(product_id)
      found = false
      compare_line = "#{product_id}\n"

      File.open(memory_filename, 'r') { |file|
        file.each_line { |line|
          next unless line == compare_line
          found = true
          break
        }
      }

      found
    end

    def remember_product_id(entity_id)
      File.open(memory_filename, 'a+') { |file| file.puts(entity_id) }
    end
  end
end
