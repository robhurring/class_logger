require File.expand_path('../../lib/class_logger', __FILE__)
$log_path = File.dirname(__FILE__)

# test module functionality
module Hello
  include ClassLogger
  has_logger :in => "#{$log_path}/%{class_name}.log", :as => :my_logger
  
  def self.alternate
    loggers[:my_logger]
  end
end
Hello.my_logger.info "Hai"
Hello.alternate.info "Hai der!"

# test class functionality
class Gateway
  include ClassLogger
  has_logger :path => $log_path, :level => Logger::ERROR
  has_logger :in => "#{$log_path}/transaction.log", :as => :transaction_logger,
    :formatter => proc{ |severity, time, program_name, message| "[%s-Transaction]: %s\n" % [severity, message] }
  
  def initialize
    logger.info "Wont show up"
    logger.error "Will show up"
  end
  
  def transact!
    transaction_logger.info "Transacted"
  end
end

g = Gateway.new
g.transact!

# test default functionality
class Default
  include ClassLogger
  has_logger :path => $log_path
end

Default.new.logger.info "Testing"