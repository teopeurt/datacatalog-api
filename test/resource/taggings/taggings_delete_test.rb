require File.expand_path('../../../test_resource_helper', __FILE__)

class TaggingsDeleteTest < RequestTestCase

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

  after do
    @tagging.destroy
    @tag.destroy
    @source.destroy
  end

  %w(normal admin).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@tagging.id}", :api_key => primary_api_key_for(role)
      end

      use "return 204 No Content"
      use "decremented tagging count"

      test "tagging should be deleted in database" do
        assert_equal nil, Tagging.find_by_id(@tagging.id)
      end
    end
  end

end
