Class Logger
============

Makes adding multiple loggers or custom loggers to any ruby class. Written mainly to have certain models in Rails log to a different file while maintaining the original logger (or overwriting it).

The idea came from [eandrejko](https://github.com/eandrejko) and his class_logger. I just added some more flexibility and made it to work outside of Rails.

Installation
------------

gem install class_logger

Options
-------

ClassLogger supports a bunch of options that are passed straight to the Logger. Most of these options should make sense, but they are described in further detail in Logger's rdoc files.

<dl>
  <dt><strong>:rotate</strong></dt>
  <dd>Set this to daily, weekly, etc. - anything Logger supports</dd>

  <dt><strong>:max_size</strong></dt>
  <dd>Set this to the size you want the log to rotate at (or set +rotate+ above)</dd>

  <dt><strong>:keep</strong></dt>
  <dd>Set this to how many logfiles you want to keep after rotating (or set +rotate+ above)</dd>

  <dt><strong>:path</strong></dt>
  <dd>The path to your log folder. (Default: "%<rails_root>s/log") -- see Interpolations section</dd>

  <dt><strong>:in</strong></dt>
  <dd>This is the name of your logfile. (Use: "%<class_name>s" to interpolate the class's name) (Default: "%<class_name>s.log") -- see Interpolations section</dd>

  <dt><strong>:as</strong></dt>
  <dd>This is the method your logger will be available to the class as. (Default: logger)</dd>

  <dt><strong>:formatter</strong></dt>
  <dd>This can be any custom proc or method you want to assign. (See Logger's rdoc files for more details on this)</dd>

  <dt><strong>:level</strong></dt>
  <dd>This is the log level</dd>
</dl>

Interpolations
--------------

The following can be used in the *path* or *in* options.

<dl>
  <dt><strong>%&lt;rails_root>s</strong></dt>
  <dd>Will replace itself with Rails.root when in a rails app</dd>

  <dt><strong>%&lt;current>s</strong></dt>
  <dd>Will replace itself with the +dirname+ of the file</dd>

  <dt><strong>%&lt;parent>s</strong></dt>
  <dd>Will replace itself with the parent directory of the file</dd>

  <dt><strong>%&lt;class_name>s</strong></dt>
  <dd>Will replace itself with the name of the class.</dd>
</dl>
  
Example Usage
-------------

<pre>
  # simple use case to override active records logger
  class Transaction < ActiveRecord::Base
    include ClassLogger
    has_logger
  
    def process!
      logger.info "Creating transation: #{amount}"  # => goes to log/transaction.log
    end
  end
  

  # custom logs for special models within rails
  # specifying a custom logfile and logger name
  class Transaction < ActiveRecord::Base
    include ClassLogger
    has_logger :in => 'gateway.log', :as => :gateway_logger
  
    def process!
      gateway_logger.info "Creating transation: #{amount}"  # => goes to log/gateway.log
      logger.info "Hello default logger!"                   # => goes to log/<environment>.log
    end
  end
  
  # overriding active record's default logger with a custom logfile
  class Transaction < ActiveRecord::Base
    include ClassLogger
    has_logger :in => 'gateway.log'
  
    def process!
      logger.info "Creating transation: #{amount}"  # => goes to log/gateway.log
    end
  end

  # create a logger for a module
  module Something
    include ClassLogger
    has_logger :path => File.expand_path("../log", __FILE__), :in => 'my_module.log'
    has_logger :path => '/var/log', :in => 'utoh.log', :as => :utoh_logger
    
    # has_logger only makes instance methods, so we need to wrap it up
    def self.logger
      self.loggers[:logger]
    end
    
    def self.utoh
      self.loggers[:utoh_logger]
    end
  end
  Something.logger.info "Testing 123"
  Something.utoh.error "oops!"
  
  # inside a class with a custom formatter
  class Something
    include ClassLogger
    has_logger :path => "%<current>s/log", :rotate => :daily, 
      :formatter => proc{ |severity, time, program_name, message| "[%s](Something): %s\n" % [severity, message] }

    def initialize
      logger.debug "Created Something."
    end
  end
  Something.new
  Something.loggers[:logger].debug "System logger"
</pre>