require File.expand_path('../../../test_resource_helper', __FILE__)

class TaggingsGetOneTest < RequestTestCase

  def app; DataCatalog::Taggings end

  before do
    @source = create_source
    @tag = create_tag(:name => "tag-1")
    @tagging = create_tagging({
      :source_id => @source.id,
      :tag_id    => @tag.id,
      :user_id   => @normal_user.id,
    })
  end

  after do
    @tagging.destroy
    @source.destroy
    @tag.destroy
  end

  shared "successful GET tagging with :id" do
    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "tag-1", parsed_response_body["tag"]["name"]
    end

   doc_properties %w(
     created_at
     id
     source
     source_id
     tag
     tag_id
     updated_at
     user_id
   )
  end

  %w(normal).each do |role|
    context "#{role} API key : get /:id" do
      before do
        get "/#{@tagging.id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET tagging with :id"

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
