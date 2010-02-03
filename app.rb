require 'rubygems'

gem 'sinatra', '>= 0.9.4', '< 1.0.0'
require 'sinatra/base'

require File.dirname(__FILE__) + '/config/config'

Sinatra::Base.set(:config, Config.environment_config)
Config.setup

base = File.dirname(__FILE__)
Dir.glob(base + '/lib/*.rb'               ).each { |f| require f }
Dir.glob(base + '/model_helpers/*.rb'     ).each { |f| require f }
Dir.glob(base + '/models/*.rb'            ).each { |f| require f }
Dir.glob(base + '/resource_helpers/*.rb'  ).each { |f| require f }
Dir.glob(base + '/resources/*.rb'         ).each { |f| require f }

MongoMapper.ensure_indexes!
