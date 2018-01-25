require 'labici/abstract_migrator'

module LaBici
  class CustomerMigrator < AbstractMigrator
    def banner
      'Migrating customers and addresses from Magento to Shopify'
    end

    def shopify_attrs_for(magento_customer)
      #billing_address = magento.address(magento_customer[:])
      #shipping_address =
    end

    def perform
      magento.customers.each do |mc|
        next if has_migrated_id?(mc[:id])

        addresses = {}
        addresses[:billing]  = magento.address(mc[:default_billing]) if mc[:default_billing]
        addresses[:shipping] = magento.address(mc[:default_shipping]) if mc[:default_shipping]

        ap({
          customer: mc,
        }.merge(addresses))
      end
    end
  end
end