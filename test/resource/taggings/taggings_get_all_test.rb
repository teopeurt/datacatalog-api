require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class TaggingsGetAllTest < RequestTestCase

  def app; DataCatalog::Taggings end

  context "0 taggings" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 taggings" do
    before do
      @source = create_source
      @tag = create_tag(:name => "tag-1")
      @taggings = 3.times.map do |n|
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

    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct tag.name attribute" do
        actual = (0 ... 3).map { |n| @members[n]["tag"]["name"] }
        3.times { |n| assert_include "tag-1", actual }
      end

      test "each element should have correct attributes" do
        @members.each do |element|
          assert_include "created_at", element
          assert_include "id", element
          assert_include "source", element
          assert_include "source_id", element
          assert_include "tag", element
          assert_include "tag_id", element
          assert_include "updated_at", element
          assert_include "user_id", element
          assert_not_include "_id", element
        end
      end
    end
  end

end
