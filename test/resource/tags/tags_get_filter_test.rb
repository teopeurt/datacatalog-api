require File.expand_path('../../../test_resource_helper', __FILE__)

class TagsGetFilterTest < RequestTestCase

  def app; DataCatalog::Tags end

  shared "successful GET of tags where text is 'tag 1'" do
    test "body should have 1 top level elements" do
      assert_equal 1, @members.length
    end

    test "each element should be correct" do
      @members.each do |element|
        assert_equal "tag 1", element["name"]
      end
    end
  end

  context "3 tags" do
    before do
      @tags = 3.times.map do |n|
        create_tag(:name => "tag #{n}")
      end
    end

    after do
      @tags.each { |x| x.destroy }
    end

    context "normal API key : get / where text is 'tag 1'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => "name='tag 1'"
        @members = parsed_response_body['members']
      end

      use "successful GET of tags where text is 'tag 1'"
    end
  end

end
