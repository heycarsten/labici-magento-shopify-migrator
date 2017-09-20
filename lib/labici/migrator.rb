require 'labici/magento'
require 'labici/shopify'

module LaBici
  class Migrator
    attr_reader :magento, :shopify

    def self.run!
      new.run!
    end

    def initialize
      @magento = Magento.new
      @shopify = Shopify.new
    end

    def run!
      ap magento.products.first
      ap shopify.products
    end
  end
end
