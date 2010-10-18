require File.expand_path('../test_helper', __FILE__)

Config.setup_mongomapper
base = File.dirname(__FILE__)
Dir.glob(base + '/../model_helpers/*.rb').each { |f| require f }
Dir.glob(base + '/../models/*.rb'       ).each { |f| require f }
require base + "/../lib/exceptions.rb"
