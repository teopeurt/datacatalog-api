class RequestTestCase < Test::Unit::TestCase

  def app
    Sinatra::Application
  end
  
  include Rack::Test::Methods
  include ModelHelpers
  include VariousHelpers
  include RequestHelpers

  before :all do
    reset_users
    @admin       = create_admin_user
    @confirmed   = create_confirmed_user
    @unconfirmed = create_unconfirmed_user
  end
  
  class << self
    alias original_context context
    
    def context(name, &block)
      klass = original_context(name, &block)
      klass.class_eval do
        test "should have JSON content type" do
          assert_equal last_response.headers["Content-Type"], "application/json"
        end
      end
    end

    def doing(&block)
      before(:all, &block)
      self
    end
    
    def should_give(mod)
      include mod
    end
  end

end
