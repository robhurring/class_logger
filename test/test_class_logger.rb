require File.expand_path('../../lib/class_logger', __FILE__)
require 'fileutils'
require 'test/unit'

$logpath = File.expand_path('../logs', __FILE__)
Dir[File.join($logpath, '*')].each{ |f| File.delete f }

def log_includes(filename, regexp)
  IO.read(filename) =~ regexp
end

module TestModule
  include ClassLogger
  has_logger :path => $logpath
  has_logger :in => File.join($logpath, 'module_named.log'), :as => :named
  has_logger :path => $logpath, :file => "module_file.log", :as => :file
  has_logger :in => "#{$logpath}/module_formatted.log", :as => :formatted, 
    :formatter => proc{ |s,t,p,m| "FORMATTED-%s: %s" % [s,m] }
end

class TestClass
  include ClassLogger
  has_logger :path => $logpath
  has_logger :in => "#{$logpath}/class_named.log", :as => :named
  has_logger :in => "#{$logpath}/level.log", :as => :level, :level => Logger::ERROR
end

class ModuleLoggerTest < Test::Unit::TestCase
  def test_log_creation
    assert File.exists?(File.join($logpath, TestModule.to_s.downcase+'.log')), '[Default] log wasnt created in the proper place'
    assert File.exists?(File.join($logpath, 'module_named.log')), '[Named] log wasnt created in the proper place'
    assert File.exists?(File.join($logpath, 'module_file.log')), '[File1] log wasnt created in the proper place'
    assert File.exists?(File.join($logpath, 'module_formatted.log')), '[Formatted] log wasnt created in the proper place'
  end
  
  def test_default_logger
    assert TestModule.logger.info("Hello")
    assert log_includes(File.join($logpath,TestModule.to_s.downcase+'.log'), /Hello/)
  end
  
  def test_named_logger
    assert TestModule.named.info("Named!")
    assert log_includes(File.join($logpath,'module_named.log'), /Named/)
  end
  
  def test_formatted_logger
    assert TestModule.formatted.info("Am i formatted?")
    assert log_includes(File.join($logpath,'module_formatted.log'), /FORMATTED-INFO: Am i formatted\?/)
  end
end

class ClassLoggerTest < Test::Unit::TestCase
  def setup
    @tc = TestClass.new
  end
  
  def test_log_creation
    assert File.exists?(File.join($logpath, TestClass.to_s.downcase+'.log')), '[Default] log wasnt created in the proper place'
  end
  
  def test_default_logger
    assert TestClass.logger.info("Hello")
    assert @tc.logger.info("Instanced!")
    assert log_includes(File.join($logpath,TestClass.to_s.downcase+'.log'), /Hello/)
  end
  
  def test_named_logger
    assert @tc.named.info("NamedINSTANCE")
    assert TestClass.named.info("NamedCLASS")
    assert log_includes(File.join($logpath,'class_named.log'), /NamedINSTANCE/)
    assert log_includes(File.join($logpath,'class_named.log'), /NamedCLASS/)
  end
  
  def test_level
    @tc.level.info "Info"
    @tc.level.error "Error"
    assert !log_includes(File.join($logpath, 'level.log'), /Info/) 
    assert log_includes(File.join($logpath, 'level.log'), /Error/) 
  end
end