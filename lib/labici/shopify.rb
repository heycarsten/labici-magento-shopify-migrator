module LaBici
  class Shopify
    def initialize
      ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_API_PASSWORD']}" \
        "@#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com/admin"
    end

    def products
      ShopifyAPI::Product.find(:all)
    end
  end
end
