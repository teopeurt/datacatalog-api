require 'rubygems'
require 'sinatra'

def require_dir(dir)
  subdir = File.expand_path(File.join(File.dirname(__FILE__), dir))
  Dir.glob("#{subdir}/*.rb").each do |f|
    require f
  end
end

require File.dirname(__FILE__) + "/config/config"

configure do
  set :config, Config.load_config_for_env(Sinatra::Application.environment)
end

require_dir 'models'
require_dir 'controllers'

before do
  content_type :json
end

helpers do
  require_dir 'helpers'
end
