require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class DeleteUsersControllerTest < RequestTestCase

  def setup_for_deletion
    user = User.create({
      :name    => "Will Not-Last-Long",
      :email   => "will.not.last.long@email.com",
      :purpose => "User account for Web application"
    })
    @id = user.id
    @user_count = User.count
  end
  
  context "anonymous user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}"
    end
    
    should_give MissingApiKey

    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "incorrect user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => "does_not_exist_in_database"
    end
    
    should_give InvalidApiKey
  
    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "unconfirmed user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @unconfirmed_user.api_key
    end
    
    should_give UnauthorizedApiKey
  
    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "confirmed user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @confirmed_user.api_key
    end
    
    should_give UnauthorizedApiKey
  
    test "should not change user count" do
      assert_equal @user_count, User.count
    end
  end
  
  context "admin user : delete /users" do
    before :all do
      setup_for_deletion
      delete "/users/#{@id}", :api_key => @admin_user.api_key
    end
    
    should_give Status200
  
    test "body should have correct id" do
      assert_include "id", parsed_response_body
      assert_equal @id, parsed_response_body["id"]
    end
    
    test "should decrement user count" do
      assert_equal @user_count - 1, User.count
    end
  end

end
