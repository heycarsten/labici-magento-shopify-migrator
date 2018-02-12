require 'labici/product_migrator'

module LaBici
  class SimpleProductMigrator < ProductMigrator
    def magento_products
      magento.products(simple_without_parent: true)
    end

    def magento_to_shopify_attrs(mp)
      attrs = super

      mag_options = magento.product_options(mp[:id]).all

      return attrs if mag_options.empty?

      option_types = mag_options.map { |row| row[:option_name] }.uniq

      if option_types.size > 3
        puts "!!!! Skipping options for: #{mp[:title]} - #{mp[:id]} (more than three)"
        return attrs
      end

      attrs[:options] = option_types.map { |ot| {
        name: ot,
        values: mag_options.
          select { |m| m[:option_name] == ot }.
          map { |m| m[:option_value] }
      } }

      options = attrs[:options].map { |o| o[:values] }

      attrs[:variants] = options[0].product(*options[1..-1]).reduce([]) { |variants, row|
        variants << Hash[
          row.each_with_index.map { |v, i| [:"option#{i + 1}", v] }
        ]
      }

      attrs
    end
  end
end
