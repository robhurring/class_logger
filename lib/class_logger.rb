module ClassLogger
  def self.included(base)
    base.extend DSL
  end
  
  module DSL
    def has_logger(options = {})
      send :extend, ClassMethods
      default_options = {
        :rotate => nil,
        :max_size => nil,
        :keep => nil,
        :path => "%<rails_root>s/log",
        :in => "%<class_name>s.log",
        :as => :logger,
        :formatter => proc{ |severity, time, program_name, message| "[%s,%s]: %s\n" % [severity, time, message] },
        :level => ::Logger::DEBUG
      }
      self.setup_logger(default_options.merge(options))
    end
  end
  
  module ClassMethods
    def loggers
      @@loggers ||= {}
    end
    
    def setup_logger(options)
      file_path = File.join(options[:path], options[:in]).to_s % \
        {:rails_root => (defined?(Rails) ? Rails.root : ''), :class_name => self.to_s.downcase}
      if (rotate = options[:rotate])
        _logger = ::Logger.new(file_path, rotate)
      else
        _logger = ::Logger.new(file_path, options[:keep], options[:max_size])
      end
      _logger.formatter = options[:formatter]
      _logger.level = options[:level]

      as = options[:as]
      self.loggers[as] = _logger
      define_method(as){ self.class.loggers[as] }
    end
  end
end