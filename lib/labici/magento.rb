module LaBici
  class Magento
    attr_reader :db

    def initialize
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

    def products
      db[:catalog_product_entity]
    end
  end
end
