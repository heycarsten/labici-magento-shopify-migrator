module LaBici
  class Migrator
    attr_reader :db, :shop

    def self.run!
      new.run!
    end

    def initialize
      connect_magento!
      connect_shopify!
    end

    def run!
      ap db[:catalog_product_entity].first
      ap ShopifyAPI::Product.find(:all)
    end

    private

    def connect_magento!
      @db = Sequel.connect(
        adapter: 'mysql2',
        encoding: 'utf8',
        database: ENV['MAGENTO_DB_NAME'],
        username: ENV['MAGENTO_DB_USER'],
        password: ENV['MAGENTO_DB_PASS'],
        host: ENV['MAGENTO_DB_HOST']
      )

      @db.extension(:pagination)
    end

    def connect_shopify!
      ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_API_PASSWORD']}" \
        "@#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com/admin"
    end
  end
end