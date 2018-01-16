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

    def product_categories(entity_id:, parent_id: nil)
      db[<<-SQL
        SELECT
          DISTINCT cce.entity_id AS id,
          ccev_path.value AS path,
          ccev_name.value AS name,
          cce.level,
          cce.parent_id
        FROM catalog_category_product ccp
        JOIN catalog_category_entity cce ON
          cce.entity_id = ccp.category_id
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
        WHERE
          ccp.product_id = #{entity_id}
          #{"AND cce.parent_id = #{parent_id}" if parent_id}
      SQL
      ]
    end

    def product_attributes
      db[<<-SQL]
        SELECT
          attribute_id,
          attribute_code,
          frontend_label,
          backend_model,
          backend_type
        FROM eav_attribute
        WHERE
          entity_type_id = 4
      SQL
    end

    def product_options(product_id)
      db[<<-SQL]
        SELECT
        FROM
          catalog_product_link pl
      SQL
    end

    def product_super_attributes(product_id)
      db[<<-SQL]
        SELECT
          sa.product_super_attribute_id AS id,
          sa.product_id AS product_id,
          sa.position AS position,
          sal.value AS label,
          sap.pricing_value AS price_value,
          sap.is_percent AS price_is_percent
        FROM
          catalog_product_super_attribute sa
        LEFT JOIN
          catalog_product_super_attribute_label sal ON
            sa.product_super_attribute_id = sal.product_super_attribute_id
        LEFT JOIN
          catalog_product_super_attribute_pricing sap ON
            sa.product_super_attribute_id = sap.product_super_attribute_id
        WHERE
          sa.product_id = #{product_id}
      SQL
    end

    def product_media_gallery(product_id)
      db[<<-SQL]
        SELECT
          g.value_id AS id,
          g.entity_id AS product_id,
          g.value AS image_path,
          gv.position AS position
        FROM
          catalog_product_entity_media_gallery g
        LEFT JOIN
          catalog_product_entity_media_gallery_value gv ON gv.value_id = g.value_id
        WHERE
          g.entity_id = #{product_id}
        ORDER BY
          gv.position
      SQL
    end

    def product_attribute_options(product_id)
      db[<<-SQL]
        SELECT
          p.entity_id,
          -- p.entity_type_id,
          -- p.attribute_set_id,
          p.type_id,
          p.sku,
          a.attribute_id,
          a.frontend_label AS attribute,
          -- a.attribute_code,
          av.value,
          ao.*
        FROM
          catalog_product_entity p
        LEFT JOIN catalog_product_entity_int av ON
          p.entity_id = av.entity_id
        LEFT JOIN eav_attribute a ON
          av.attribute_id = a.attribute_id
        LEFT JOIN eav_attribute_option_value ao ON
          av.value = ao.option_id
        WHERE
          p.entity_id = #{product_id}
      SQL
    end

    def products(manufacturer_value: nil, entity_type_id: nil, entity_ids: nil)
      db[<<-SQL]
        SELECT
          e.entity_id AS id,
          e.sku AS sku,
          v1.value AS title,
          v3.value AS description,
          v4.value AS short_description,
          v2.value AS image_path,
          cpf.manufacturer_value AS vendor,
          si.qty AS quantity,
          d1.value AS price
        FROM
          catalog_product_entity e
        LEFT JOIN
          catalog_product_flat_1 cpf ON cpf.entity_id = e.entity_id
        LEFT JOIN
          cataloginventory_stock_item si ON e.entity_id = si.product_id
        LEFT JOIN
          catalog_product_entity_varchar v1 ON e.entity_id = v1.entity_id
            AND v1.store_id = 0
            AND v1.attribute_id = (
              SELECT attribute_id
              FROM eav_attribute
              WHERE
                attribute_code = 'name' AND
                entity_type_id = (
                  SELECT entity_type_id
                    FROM eav_entity_type
                    WHERE entity_type_code = 'catalog_product'
                )
            )
        LEFT JOIN
          catalog_product_entity_varchar v5 ON e.entity_id = v5.entity_id
            AND v5.store_id = 0
            AND v5.attribute_id = (
              SELECT attribute_id
              FROM eav_attribute
              WHERE
                attribute_code = 'manufacturer' AND
                entity_type_id = (
                  SELECT entity_type_id
                  FROM eav_entity_type
                  WHERE entity_type_code = 'catalog_product'
                )
            )
        LEFT JOIN
          catalog_product_entity_text v4 ON e.entity_id = v4.entity_id
            AND v4.store_id = 0
            AND v4.attribute_id = (
              SELECT attribute_id
                FROM eav_attribute
                WHERE
                  attribute_code = 'short_description' AND
                  entity_type_id = (
                    SELECT entity_type_id
                    FROM eav_entity_type
                    WHERE entity_type_code = 'catalog_product'
                  )
            )
        LEFT JOIN
          catalog_product_entity_text v3 ON e.entity_id = v3.entity_id
            AND v3.store_id = 0
            AND v3.attribute_id = (
              SELECT attribute_id
              FROM eav_attribute
              WHERE
                attribute_code = 'description' AND
                entity_type_id = (
                  SELECT entity_type_id
                  FROM eav_entity_type
                  WHERE entity_type_code = 'catalog_product'
                )
            )
        LEFT JOIN
          catalog_product_entity_varchar v2 ON e.entity_id = v2.entity_id
            AND v2.store_id = 0
            AND v2.attribute_id = (
              SELECT attribute_id
              FROM eav_attribute
              WHERE attribute_code = 'image' AND
                entity_type_id = (
                  SELECT entity_type_id
                  FROM eav_entity_type
                  WHERE entity_type_code = 'catalog_product'
                )
            )
        LEFT JOIN
          catalog_product_entity_decimal d1 ON e.entity_id = d1.entity_id
            AND d1.store_id = 0
            AND d1.attribute_id = (
              SELECT attribute_id
              FROM eav_attribute
              WHERE
                attribute_code = 'price' AND
                entity_type_id = (
                  SELECT entity_type_id
                  FROM eav_entity_type
                  WHERE entity_type_code = 'catalog_product'
                )
            )
#{"WHERE cpf.manufacturer_value = '#{manufacturer_value}'" if manufacturer_value}
#{"WHERE e.type_id = '#{entity_type_id}'" if entity_type_id}
#{"WHERE e.entity_id IN (#{entity_ids.join(',')})" if entity_ids}
      SQL
    end
  end
end
