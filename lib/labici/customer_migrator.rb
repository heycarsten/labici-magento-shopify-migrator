require 'labici/abstract_migrator'
require 'date'

module LaBici
  class CustomerMigrator < AbstractMigrator
    def banner
      'Migrating customers and addresses from Magento to Shopify'
    end

    def shopify_address_for(magento_address_id)
      ma = magento.address(magento_address_id)

      return unless ma

      { address1:   ma[:street],
        city:       ma[:city],
        province:   ma[:province_code],
        country:    ma[:country_id],
        phone:      ma[:telephone],
        zip:        ma[:postcode],
        last_name:  ma[:lastname],
        first_name: ma[:firstname] }
    end

    def shopify_addresses_for(mc)
      addresses = []

      if mc[:default_billing] && mc[:default_shipping]
        addresses << shopify_address_for(mc[:default_billing])

        if mc[:default_billing] != mc[:default_shipping]
          addresses << shopify_address_for(mc[:default_shipping])
        end
      elsif mc[:default_billing]
        addresses << shopify_address_for(mc[:default_billing])
      elsif mc[:default_shipping]
        addresses << shopify_address_for(mc[:default_shipping])
      end

      # Some referenced addresses are no longer in Magento
      addresses.compact!

      if (default_addr = addresses.first)
        default_addr[:default] = true
      end

      addresses
    end

    def shopify_attrs_for(mc) # Magento Customer
      h         = {}
      phone     = nil
      addresses = shopify_addresses_for(mc)

      if (default_address = addresses.first)
        phone = default_address[:phone]
      end

      h[:email]              = mc[:email]
      h[:first_name]         = mc[:firstname]
      h[:last_name]          = mc[:lastname]
      h[:verified_email]     = mc[:confirmation].nil?
      h[:send_email_welcome] = false
      h[:phone]              = phone if phone
      h[:addresses]          = addresses if addresses.any?

      h[:metafields] = [{
        key:        'prev_created_at',
        value:      mc[:created_at].to_datetime.iso8601,
        value_type: 'string',
        namespace:  'global'
      }]

      h
    end

    def perform
      magento.customers.each do |mc|
        next if has_migrated_id?(mc[:id])

        notify_start_task("#{mc[:firstname]} #{mc[:lastname]} (#{mc[:email]})")

        shopify_attrs    = shopify_attrs_for(mc)
        shopify_customer = shopify.create_customer(shopify_attrs)

        if shopify_customer.valid?
          remember_ids(mc[:id], shopify_customer.id)
          notify_success
        else
          notify_failure
          ap shopify_attrs
          ap shopify_customer.errors
          next
        end
      end
    end
  end
end
