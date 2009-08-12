require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesPostControllerTest < RequestTestCase

  before do
    @source_count = Source.count
  end

  # - - - - - - - - - -

  context "anonymous user : post /sources" do
    before do
      post '/sources'
    end
    
    use "return 401 because the API key is missing"
    use "unchanged source count"
  end
  
  context "incorrect user : post /sources" do
    before do
      post '/sources', :api_key => "does_not_exist_in_database"
    end
    
    use "return 401 because the API key is invalid"
    use "unchanged source count"
  end
  
  context "normal user : post /sources" do
    before do
      post '/sources', :api_key => @normal_user.primary_api_key
    end
    
    use "return 401 because the API key is unauthorized"
    use "unchanged source count"
  end
  
  # - - - - - - - - - -

  context "admin user : post /sources : protected param 'updated_at'" do
    before do
      post '/sources', {
        :api_key    => @admin_user.primary_api_key,
        :url        => "http://data.gov/sources/A",
        :updated_at => Time.now.to_json
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged source count"
  
    test "body should say 'updated_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "updated_at", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  context "admin user : post /sources : extra param 'junk'" do
    before do
      post '/sources', {
        :api_key => @admin_user.primary_api_key,
        :url     => "http://data.gov/sources/A",
        :junk    => "This is an extra parameter (junk)"
      }
    end
  
    use "return 400 Bad Request"
    use "unchanged source count"
  
    test "body should say 'junk' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "junk", parsed_response_body["errors"]["invalid_params"]
    end
  end
  
  # - - - - - - - - - -
  
  context "admin user : post /sources : correct params" do
    before do
      post '/sources', {
        :api_key   => @admin_user.primary_api_key,
        :url       => "http://data.gov/sources/A"
      }
    end
    
    use "return 201 Created"
    use "return timestamps and id in body" 
    use "incremented source count"
      
    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/sources/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end
    
    test "body should have correct url" do
      assert_equal "http://data.gov/sources/A", parsed_response_body["url"]
    end
    
    test "url should be correct in database" do
      source = Source.find_by_id(parsed_response_body["id"])
      assert_equal "http://data.gov/sources/A", source.url
    end
  end

end
