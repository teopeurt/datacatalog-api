require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class UsersKeysGetOneControllerTest < RequestTestCase

  before do
    @user = User.create({
      :name    => "Example User",
      :email   => "example.user@email.com",
      :purpose => "User account for Web application"
    })
    api_key = ApiKey.new({
      :api_key  => @user.generate_api_key,
      :key_type => "primary",
      :purpose  => "Primary API key"
    })
    @user.api_keys << api_key
    @user.save!
    @api_key_id = @user.api_keys[0].id
    @fake_id = get_fake_mongo_object_id
  end

  # - - - - - - - - - -

  context "anonymous : get /users/:id/keys/:id" do
    before do
      get "/users/#{@user.id}/keys/#{@api_key_id}"
    end
    
    use "return 401 because the API key is missing"
  end
  
  context "incorrect API key : get /users/:id/keys/:id" do
    before do
      get "/users/#{@user.id}/keys/#{@api_key_id}",
        :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
  end
  
  context "normal API key : get /users/:id/keys/:id" do
    before do
      get "/users/#{@user.id}/keys/#{@api_key_id}",
        :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
  end
  
  # - - - - - - - - - -

  context "admin API key : get /users/:fake_id/keys/:id : not found" do
    before do
      get "/users/#{@fake_id}/keys/#{@api_key_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin API key : get /users/:id/keys/:fake_id : not found" do
    before do
      get "/users/#{@user.id}/keys/#{@fake_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end
  
  context "admin API key : get /users/:fake_id/keys/:fake_id : not found" do
    before do
      get "/users/#{@fake_id}/keys/#{@fake_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 404 Not Found"
    use "return an empty response body"
  end

  # - - - - - - - - - -

  context "admin API key : get /users/:id/keys/:id : found" do
    before do
      get "/users/#{@user.id}/keys/#{@api_key_id}",
        :api_key => @admin_user.primary_api_key
    end
    
    use "return 200 Ok"

    test "body should have correct purpose" do
      assert_equal "Important!", parsed_response_body["purpose"]
    end

    test "body should have well formed API key" do
      assert_equal 40, parsed_response_body["api_key"].length
    end

    test "body should not have _id" do
      assert_not_include "_id", parsed_response_body
    end

    test "body should have created_at" do
      assert_include "created_at", parsed_response_body
    end

    test "body should not have updated_at" do
      assert_not_include "updated_at", parsed_response_body
    end
  end

end
