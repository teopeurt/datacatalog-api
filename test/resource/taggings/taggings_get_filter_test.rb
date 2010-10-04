require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TaggingsGetFilterTest < RequestTestCase

  def app; DataCatalog::Taggings end

  # Probably shouldn't be able to create multiple Taggings
  # for the same Source/Tag combo
  context "6 taggings" do
    before do
      @source = create_source
      @tag = create_tag(:name => "tag-1")
      @taggings = 6.times.map do |n|
        create_tagging({
          :source_id => @source.id,
          :tag_id    => @tag.id,
          :user_id   => @normal_user.id,
        })
      end
    end

    after do
      @taggings.each { |x| x.destroy }
      @tag.destroy
      @source.destroy
    end

    context "normal API key : get / where tag_id is the tag's id" do
      before do
        get "/", {
          :api_key => @normal_user.primary_api_key,
          :filter  => %(tag_id="#{@tag.id}")
        }
        @members = parsed_response_body['members']
      end

      test "body should have 6 top level elements" do
        assert_equal 6, @members.length
      end

      test "each element should be correct" do
        @members.each do |element|
          assert_equal @tag.id.to_s, element["tag_id"]
          assert_equal @source.id.to_s, element["source_id"]
          assert_equal @normal_user.id.to_s, element["user_id"]
        end
      end
    end
  end

end
