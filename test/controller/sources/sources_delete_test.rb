require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesDeleteControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    source = Source.create(
      :title => "The Original Data Source",
      :url   => "http://data.gov/original"
    )
    @id = source.id
    @source_count = Source.count
    @fake_id = get_fake_mongo_object_id
  end

  shared "attempted DELETE source with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "unchanged source count"
  end

  shared "successful DELETE source with :id" do
    use "return 204 No Content"
    use "decremented source count"

    test "source should be deleted in database" do
      assert_equal nil, Source.find_by_id(@id)
    end
  end

  shared "attempted double DELETE source with :id" do
    use "return 404 Not Found"
    use "return an empty response body"
    use "decremented source count"

    test "should be deleted in database" do
      assert_equal nil, Source.find_by_id(@id)
    end
  end
  
  context "delete /" do
    context "anonymous" do
      before do
        delete "/#{@id}"
      end

      use "return 401 because the API key is missing"
      use "unchanged source count"
    end

    context "incorrect API key" do
      before do
        delete "/#{@id}", :api_key => "does_not_exist_in_database"
      end

      use "return 401 because the API key is invalid"
      use "unchanged source count"
    end

    context "normal API key" do
      before do
        delete "/#{@id}", :api_key => @normal_user.primary_api_key
      end

      use "return 401 because the API key is unauthorized"
      use "unchanged source count"
    end
  end
  
  %w(curator admin).each do |role|
    context "#{role} API key : delete /:fake_id" do
      before do
        delete "/#{@fake_id}", :api_key => primary_api_key_for(role)
      end
  
      use "attempted DELETE source with :fake_id"
    end
  
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@id}", :api_key => primary_api_key_for(role)
      end
    
      use "successful DELETE source with :id"
    end

  #   context "#{role} API key : double delete /users" do
  #     before do
  #       delete "/#{@id}", :api_key => primary_api_key_for(role)
  #       delete "/#{@id}", :api_key => primary_api_key_for(role)
  #     end
  #   
  #     use "attempted double DELETE source with :id"
  #   end
  # 
  #   context "#{role} API key : double delete /users" do
  #     before do
  #       delete "/#{@id}", :api_key => primary_api_key_for(role)
  #       delete "/#{@id}", :api_key => primary_api_key_for(role)
  #     end
  #   
  #     use "attempted double DELETE source with :id"
  #   end
  end
  
end
