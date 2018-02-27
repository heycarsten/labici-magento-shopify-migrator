module LaBici
  class AbstractMigrator
    attr_reader :magento, :shopify

    def self.run!(*args)
      new.run!(*args)
    end

    def self.underscore(str)
      str.
        split('::').
        last.
        gsub(/[A-Z]{1}/) { |s| "_#{s.downcase}" }.sub(/\A_/, '')
    end

    def initialize(*args)
      @magento = Magento.new
      @shopify = Shopify.new
      FileUtils.touch(memory_filename)
    end

    def label
      @label ||= self.class.underscore(self.class.to_s).tr('_', '-')
    end

    def banner
      raise NotImplementedError
    end

    def run!(*args)
      puts "==== [#{label}] #{banner}"
      perform
      puts "---- Done!"
    end

    def root
      @root ||= File.expand_path('../../..', __FILE__)
    end

    def notify_start_task(msg)
      print "---> #{msg} ... "
    end

    def notify_success
      puts '✅'
    end

    def notify_failure
      puts '💔'
    end

    def memory_file
      'migrated_' + self.class.underscore(self.class.to_s).sub('_migrator', '')
    end

    def memory_filename
      @memory_filename ||= File.join(root, "data/#{memory_file}_ids.txt")
    end

    def has_migrated_id?(magento_id)
      found = false

      File.open(memory_filename, 'r') { |file|
        file.each_line { |line|
          next unless /\A#{magento_id},/ =~ line
          found = true
          break
        }
      }

      found
    end

    def remember_ids(magento_id, shopify_id)
      File.open(memory_filename, 'a+') { |file|
        file.puts("#{magento_id},#{shopify_id}")
      }
    end
  end
end
