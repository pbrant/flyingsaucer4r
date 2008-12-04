require 'flyingsaucer/version.rb'

Dir.glob(File.join(File.dirname(__FILE__), "*.jar")) { |jar| require File.basename(jar) }

