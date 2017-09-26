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

    def categories
      db[<<-SQL
        SELECT
          DISTINCT cce.entity_id AS id,
          ccev_path.value AS path,
          ccev_name.value AS name,
          cce.level,
          cce.parent_id
        FROM catalog_category_entity cce
        JOIN eav_entity_type ee ON
          cce.entity_type_id = ee.entity_type_id AND
          ee.entity_model = 'catalog/category'
        LEFT JOIN catalog_category_entity_varchar ccev_path ON
          ccev_path.entity_id = cce.entity_id AND
          ccev_path.attribute_id = (
            SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'url_path' LIMIT 1
          )
        LEFT JOIN catalog_category_entity_varchar ccev_name ON
          ccev_name.entity_id = cce.entity_id AND
          ccev_name.attribute_id = (
            SELECT attribute_id FROM eav_attribute WHERE attribute_code  = 'name' LIMIT 1
          )
      SQL
      ]
    end

    def products
      db[:catalog_product_entity]
    end
  end
end
