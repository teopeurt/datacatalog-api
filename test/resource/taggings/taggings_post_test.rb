require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TaggingsPostTest < RequestTestCase

  def app; DataCatalog::Taggings end

  before do
    @source = create_source
    @tag = create_tag(:name => "tag-1")
    @tagging = create_tagging({
      :source_id => @source.id,
      :tag_id    => @tag.id,
      :user_id   => @normal_user.id,
    })
    @tagging_count = Tagging.count
  end

  %w(normal admin).each do |role|
    context "#{role} API key : post / with correct params" do
      before do
        post "/", {
          :api_key   => primary_api_key_for(role),
          :source_id => @source.id,
          :tag_id    => @tag.id
        }
      end

      use "return 201 Created"
      use "incremented tagging count"

      test "location header should point to new resource" do
        assert_include "Location", last_response.headers
        new_uri = "http://localhost:4567/taggings/" + parsed_response_body["id"]
        assert_equal new_uri, last_response.headers["Location"]
      end

      test "body should have correct text" do
        assert_equal @source.id.to_s, parsed_response_body["source_id"]
        assert_equal @tag.id.to_s, parsed_response_body["tag_id"]
      end

     test "fields should be correct in database" do
       tag = Tagging.find_by_id!(parsed_response_body["id"])
       assert_equal @source.id, tag.source_id
       assert_equal @tag.id, tag.tag_id
     end
    end
  end

end
