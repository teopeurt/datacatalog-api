require File.expand_path('../../../test_resource_helper', __FILE__)

class CommentsGetFilterTest < RequestTestCase

  def app; DataCatalog::Comments end

  context "6 comments" do
    before do
      @user = create_user
      @sources = 3.times.map do |i|
        create_source
      end
      @comments = 6.times.map do |i|
        k = i % 3
        create_comment(
          :text      => "comment #{k}",
          :user_id   => @user.id,
          :source_id => @sources[k].id
        )
      end
    end

    after do
      @comments.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
      @user.destroy
    end

    context "normal API key : get / where text is 'comment 1'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => %(text="comment 1")
        @members = parsed_response_body['members']
      end

      test "body should have 2 top level elements" do
        assert_equal 2, @members.length
      end

      test "each element should be correct" do
        @members.each do |element|
          assert_equal "comment 1", element["text"]
          assert_equal @user.id.to_s, element["user_id"]
          assert_equal @sources[1].id.to_s, element["source_id"]
        end
      end
    end

  end

end
