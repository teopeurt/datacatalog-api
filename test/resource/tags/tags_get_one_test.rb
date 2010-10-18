require File.expand_path('../../../test_resource_helper', __FILE__)

class TagsGetOneTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    @tag = create_tag(:name => "Tag A")
  end

  after do
    @tag.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@tag.id}", :api_key => @normal_user.primary_api_key
    end

    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "Tag A", parsed_response_body["name"]
    end

    doc_properties %w(
      created_at
      id
      name
      slug
      source_count
      updated_at
    )
  end

end
