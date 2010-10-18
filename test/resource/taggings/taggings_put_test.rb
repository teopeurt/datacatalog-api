require File.expand_path('../../../test_resource_helper', __FILE__)

class TaggingsPutTest < RequestTestCase

  def app; DataCatalog::Taggings end

  before :all do
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
    context "#{role} API key : put /:id with correct param" do
      before do
        put "/#{@tagging.id}", {
          :api_key   => primary_api_key_for(role),
          :source_id => @source.id,
          :tag_id    => @tag.id
        }
      end

      use "return 200 Ok"
      use "unchanged tagging count"

      test "field should be updated in database" do
        @tag.name = "new-tag"
        @tag.save
        tag = Tag.find_by_id!(@tagging.tag_id)
        assert_equal "new-tag", tag.name
      end
    end
  end

end
