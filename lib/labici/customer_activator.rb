require 'labici/shopify'
require 'csv'

module LaBici
  class CustomerActivator
    def initialize
      @api = LaBici::Shopify.new
      @db = Sequel.sqlite(File.join(root, 'data/customers.db'))
      init_db!
    end

    def root
      @root ||= File.expand_path('../../..', __FILE__)
    end

    def init_db!
      @db.create_table? :customers do
        primary_key :id
        column :email, :string, unique: true, null: false
        column :first_name, :string
        column :last_name, :string
        column :activation_url, :string, index: true
        column :generated_at, :datetime, index: true
      end
    end

    def load_db!
      CSV.foreach(File.join(root, 'data/customers.csv'), headers: true) do |row|
        next if row['Email'].blank?
        next if @db[:customers].where(email: row['Email']).any?

        @db[:customers] << {
          email: row['Email'],
          first_name: row['First Name'],
          last_name: row['Last Name']
        }
      end
    end

    def export_csv!
      CSV.open(File.join(root, 'data/customers-with-activation-urls.csv'), 'wb') do |csv|
        csv << ['Email', 'First Name', 'Last Name', 'Activation URL']

        @db[:customers].where(Sequel.lit('activation_url IS NOT NULL')).each do |c|
          csv << [c[:email], c[:first_name], c[:last_name], c[:activation_url]]
        end
      end
    end

    def sync_activation_urls!
      puts

      @db[:customers].where(activation_url: nil).each do |customer|
        res = @api.search_customers(customer[:email])
        sleep 0.5

        if res.size != 1
          puts "\n[SKIP] #{customer[:email]}: Multiple results returned from API\n\n---\n#{res.inspect}"
          next
        end

        if res[0].email != customer[:email]
          puts "\n[SKIP] #{customer[:email]}: API response has different email (#{res[0].email.inspect}"
          next
        end

        begin
          url = res[0].account_activation_url
          sleep 0.45

          @db[:customers].where(id: customer[:id]).update(
            activation_url: url,
            generated_at: Time.now
          )

          print "✅"
          STDOUT.flush
        rescue ActiveResource::ResourceInvalid => e
          puts "\n[SKIP] #{customer[:email]}: Unable to generate activation URL\n\n---\n#{e.class}\n\n#{e.message}"
          next
        end
      end
    end
  end
end
