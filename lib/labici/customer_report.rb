require 'csv'

module LaBici
  class CustomerReport
    attr_reader :magento

    def self.run!(output_file = nil)
      new(output_file).run!
    end

    def initialize(output_csv)
      #@csv = CSV.open(output_csv || STDOUT)
      @magento = Magento.new
    end

    def run!
      puts "==== [customer-report] Generating CSV of customers + sales"
      perform
      puts "---- Done!"
    end

    def notify_start_task(msg)
      print "---> #{msg} ... "
    end

    def perform
      ap magento.total_invoiced_by_customer
    end

    def notify_success
      puts '✅'
    end

    def notify_failure
      puts '💔'
    end
  end
end