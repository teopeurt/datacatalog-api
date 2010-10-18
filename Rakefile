require 'rubygems'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rcov/rcovtask'

require File.expand_path('../config/config', __FILE__)
Dir.glob(File.expand_path('../tasks/*.rake', __FILE__)).each { |f| load f }

desc "Default: run all tests"
task :default => :test

namespace :environment do
  task :application do
    puts "Loading application environment..."
    require File.expand_path('../app', __FILE__)
  end

  task :models do
    puts "Loading models..."
    Config.setup_mongomapper
    base = File.expand_path('..', __FILE__)
    Dir.glob(base + '/model_helpers/*.rb').each { |f| require f }
    Dir.glob(base + '/models/*.rb'       ).each { |f| require f }
  end
end
