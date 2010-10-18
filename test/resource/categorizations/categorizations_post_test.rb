require File.expand_path('../../../test_resource_helper', __FILE__)

class CategorizationsPostTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  before do
    @source = create_source
    @category = create_category(:name => "Category 1")
    @categorization = create_categorization(:source_id => @source.id, :category_id => @category.id)
    @categorization_count = Categorization.count
  end

  context "curator API key : post / with correct params" do
    before do
      post "/", {
        :api_key     => @curator_user.primary_api_key,
        :source_id   => @source.id,
        :category_id => @category.id
      }
    end

    use "return 201 Created"
    use "incremented categorization count"

    test "location header should point to new resource" do
      assert_include "Location", last_response.headers
      new_uri = "http://localhost:4567/categorizations/" + parsed_response_body["id"]
      assert_equal new_uri, last_response.headers["Location"]
    end

    test "body should have correct text" do
      assert_equal @source.id.to_s, parsed_response_body["source_id"]
      assert_equal @category.id.to_s, parsed_response_body["category_id"]
    end

   test "fields should be correct in database" do
     category = Categorization.find_by_id!(parsed_response_body["id"])
     assert_equal @source.id, category.source_id
     assert_equal @category.id, category.category_id
   end
  end

end
