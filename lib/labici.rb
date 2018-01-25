require 'bundler/setup'
require 'dotenv/load'
require 'shopify_api'
require 'sequel'
require 'ap'

module LaBici
end

require 'labici/configurable_product_migrator'
require 'labici/simple_product_migrator'
require 'labici/customer_migrator'
