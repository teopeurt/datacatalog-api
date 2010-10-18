require File.expand_path('../../../test_resource_helper', __FILE__)

class TagsGetAllTest < RequestTestCase

  def app; DataCatalog::Tags end

  context "0 tags" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 tags" do
    before do
      @tags = 3.times.map do |n|
        create_tag(:name => "Tag #{n}")
      end
    end

    after do
      @tags.each { |x| x.destroy }
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct name" do
        actual = (0 ... 3).map { |n| @members[n]["name"] }
        3.times { |n| assert_include "Tag #{n}", actual }
      end
    end
  end

end
