require File.dirname(__FILE__) + '/config/config'
require 'sinatra/base'

Sinatra::Base.set(:config, Config.environment_config)
Config.setup

base = File.dirname(__FILE__)
Dir.glob(base + '/lib/*.rb'             ).each { |f| require f }
Dir.glob(base + '/model_helpers/*.rb'   ).each { |f| require f }
Dir.glob(base + '/models/*.rb'          ).each { |f| require f }
Dir.glob(base + '/resource_helpers/*.rb').each { |f| require f }
Dir.glob(base + '/resources/*.rb'       ).each { |f| require f }
