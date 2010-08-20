require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class CategorizationsGetOneTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  before do
    @source = create_source
    @category = create_category(:name => "Category 1")
    @categorization = create_categorization(
      :source_id => @source.id,
      :category_id => @category.id
    )
  end

  after do
    @categorization.destroy
    @source.destroy
    @category.destroy
  end

  shared "successful GET categorization with :id" do
    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "Category 1", parsed_response_body["category"]["name"]
    end

   doc_properties %w(
     category
     category_id
     created_at
     id
     source
     source_id
     updated_at
   )
  end

  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@categorization.id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET categorization with :id"

      test "body should have correct source_id" do
        assert_equal @source.id.to_s, parsed_response_body["source_id"]
      end

      test "body should have correct source" do
        actual = parsed_response_body["source"]
        expected = {
          "href"  => "/sources/#{@source.id}",
          "title" => "2005-2007 American Community Survey PUMS Housing File",
        }
        assert_equal expected, actual
      end
    end
  end

end
