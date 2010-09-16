require 'rubygems'
begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  puts "Please run `gem install bundler` and `bundle install`"
end
require 'test/unit'
require 'rack/test'
require 'crack/json'
require 'pending'
require 'rr'
require 'tu-context'

base = File.dirname(__FILE__)
Dir.glob(base + '/helpers/test_helpers/*.rb').each { |f| require f }
Dir.glob(base + '/helpers/test_cases/*.rb'  ).each { |f| require f }
Dir.glob(base + '/helpers/assertions/*.rb'  ).each { |f| require f }
Dir.glob(base + '/helpers/shared/*.rb'      ).each { |f| require f }

require File.dirname(__FILE__) + '/../config/config'
Config.environment = 'test'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

# If you use `rake test` the database will automatically get dropped.
# If you are running tests outside of rake (e.g. in TextMate), you
# might want to drop the database here:
Config.drop_database
