require File.expand_path('../config/config', __FILE__)
require 'sinatra/base'

Sinatra::Base.set(:config, Config.environment_config)
Config.setup

base = File.expand_path('..', __FILE__)
Dir.glob(base + '/lib/*.rb'             ).each { |f| require f }
Dir.glob(base + '/model_helpers/*.rb'   ).each { |f| require f }
Dir.glob(base + '/models/*.rb'          ).each { |f| require f }
Dir.glob(base + '/resource_helpers/*.rb').each { |f| require f }
Dir.glob(base + '/resources/*.rb'       ).each { |f| require f }
