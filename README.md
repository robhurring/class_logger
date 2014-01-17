Class Logger
============

[![Build Status](https://travis-ci.org/robhurring/class_logger.png?branch=master)](https://travis-ci.org/robhurring/class_logger)

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
  <dd>The path to your log folder. (Default: "%{rails_root}/log") -- see Interpolations section</dd>

  <dt><strong>:file</strong></dt>
  <dd>This is the name of your logfile. (Use: "%{class_name}" to interpolate the class's name) (Default: "%{class_name}.log") -- see Interpolations section</dd>

  <dt><strong>:in</strong></dt>
  <dd><strong>Overrides :file &amp; :path!</strong> If you include this setting, it will break the filename from the path and use those options.</dd>

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
  <dt><strong>%{rails_root}</strong></dt>
  <dd>Will replace itself with Rails.root when in a rails app</dd>

  <dt><strong>%{class_name}</strong></dt>
  <dd>Will replace itself with the name of the class.</dd>
</dl>

Example Usage
-------------

```ruby
  # simple use case to override active records logger
  class Transaction &lt; ActiveRecord::Base
    include ClassLogger
    has_logger

    def process!
      logger.info "Creating transation: #{amount}"  # => goes to RAILS_ROOT/log/transaction.log
    end
  end


  # custom logs for special models within rails
  # specifying a custom logfile and logger name
  class Transaction &lt; ActiveRecord::Base
    include ClassLogger
    has_logger :file => 'gateway.log', :as => :gateway_logger

    def process!
      gateway_logger.info "Creating transation: #{amount}"  # => goes to RAILS_ROOT/log/gateway.log
      logger.info "Hello default logger!"                   # => goes to default rails logger
    end
  end

  # overriding active record's default logger with a custom logfile
  class Transaction &lt; ActiveRecord::Base
    include ClassLogger
    has_logger :file => 'gateway.log'

    def process!
      logger.info "Creating transation: #{amount}"  # => goes to RAILS_ROOT/log/gateway.log
    end
  end

  # create a logger for a module
  module Something
    include ClassLogger
    has_logger :in => "#{File.dirname(__FILE__)}/log/my_module.log"
    has_logger :in => "/var/log/utoh.log", :as => :utoh_logger
  end
  Something.logger.info "Testing 123" # => goes to ./log/my_module.log
  Something.utoh_logger.error "oops!" # => goes to /var/log/utoh.log

  # inside a class with a custom formatter
  class Something
    include ClassLogger
    has_logger :path => File.expand_path("../log", __FILE__), :rotate => :daily,
      :formatter => proc{ |severity, time, program_name, message| "[%s](Something): %s\n" % [severity, message] }

    def initialize
      logger.debug "Created Something." # => goes to ../log/something.log
    end
  end
  Something.new
  Something.loggers[:logger].debug "System logger" # alter entry point to logger
```