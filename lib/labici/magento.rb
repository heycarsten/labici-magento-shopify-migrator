module LaBici
  class Magento
    attr_reader :db

    def initialize
      @db = Sequel.connect(
        adapter: 'mysql2',
        encoding: 'utf8',
        database: ENV['MYSQL_DATABASE'],
        username: ENV['MYSQL_USER'],
        password: ENV['MYSQL_ROOT_PASSWORD'],
        host: ENV['MYSQL_HOST']
      )

      @db.extension(:pagination)
    end

    def products
      db[:catalog_product_entity]
    end
  end
end
