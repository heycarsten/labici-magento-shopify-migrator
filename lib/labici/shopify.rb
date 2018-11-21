require 'base64'

module LaBici
  class Shopify
    API_WAIT_SECS = 0.55

    def initialize
      ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_API_PASSWORD']}" \
        "@#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com/admin"
    end

    def search_customers(query)
      ShopifyAPI::Customer.search(query: query)
    end

    def create_customer(first_name:, last_name:, email:, verified_email:, phone: nil, addresses: nil, send_email_welcome: false, metafields: nil)
      customer = ShopifyAPI::Customer.new

      customer.first_name         = first_name
      customer.last_name          = last_name
      customer.email              = email
      customer.verified_email     = verified_email
      customer.phone              = phone if phone
      customer.send_email_welcome = send_email_welcome
      customer.addresses          = addresses if addresses
      customer.metafields         = metafields if metafields

      customer.save

      sleep API_WAIT_SECS

      customer
    end

    def create_product(title:, body_html:, vendor:, product_type:, options: nil, variants: nil, price:, sku:, tags: [], images: nil, meta_title_tag: nil, meta_description_tag: nil)
      product = ShopifyAPI::Product.new

      product.title = title
      product.body_html = body_html
      product.vendor = vendor
      product.metafields_global_title_tag = meta_title_tag if meta_title_tag
      product.metafields_global_description_tag = meta_description_tag if meta_description_tag
      product.product_type = product_type
      product.tags = tags.join(', ')
      product.options = options if options
      product.variants = variants || [{ position: 1, price: price, sku: sku }]

      image_payloads = Array(images).map { |image| {
        attachment: encode_image(image[:file]),
        position: image[:position]
      } }

      if image_payloads.any?
        product.images = image_payloads
      end

      product.save

      sleep API_WAIT_SECS

      product
    end

    def encode_image(image_file)
      unless File.exists?(image_file)
        STDOUT.puts("WARNING: Image file not found! #{image_file}")
        return
      end

      Base64.encode64(File.open(image_file, 'rb') { |file| file.read })
    end
  end
end
