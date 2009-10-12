require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class SourcesGetOneControllerTest < RequestTestCase

  def app; DataCatalog::Sources end

  before do
    source = Source.create(
      :title => "The Original Data Source",
      :url   => "http://data.gov/original"
    )
    @id = source.id
    @fake_id = get_fake_mongo_object_id
  end

  shared "attempted GET source with :fake_id" do
    use "return 404 Not Found"
    use "return an empty response body"
  end

  shared "successful GET source with :id" do
    use "return 200 Ok"
    use "return timestamps and id in body"
  
    test "body should have correct text" do
      assert_equal "http://data.gov/original", parsed_response_body["url"]
    end

    test "body should have correct attributes" do
      assert_include "title", parsed_response_body
      assert_include "url", parsed_response_body
      assert_include "released", parsed_response_body
      assert_include "period_start", parsed_response_body
      assert_include "period_end", parsed_response_body
      assert_include "ratings_total", parsed_response_body
      assert_include "ratings_count", parsed_response_body
    end
  end

  context_ "get /:id" do
    context "anonymous" do
      before do
        get "/#{@id}"
      end

      use "return 401 because the API key is missing"
    end

    context "incorrect API key" do
      before do
        get "/#{@id}", :api_key => "does_not_exist_in_database"
      end

      use "return 401 because the API key is invalid"
    end
  end
  
  %w(normal curator admin).each do |role|
    context "#{role} API key : get /:fake_id" do
      before do
        get "/#{@fake_id}", :api_key => primary_api_key_for(role)
      end

      use "attempted GET source with :fake_id"
    end

    context "#{role} API key : get /:id" do
      before do
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET source with :id"
    end

    context "#{role} API key : 2 ratings : get /:id" do
      before do
        @ratings = [
          create_source_rating(
            :value     => 1,
            :source_id => @id
          ),
          create_source_rating(
            :value     => 5,
            :source_id => @id
          )
        ]
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end
      
      use "successful GET source with :id"
      
      test "body should have correct ratings_total" do
        assert_equal 6, parsed_response_body["ratings_total"]
      end

      test "body should have correct ratings_count" do
        assert_equal 2, parsed_response_body["ratings_count"]
      end
    end

    context "#{role} API key : 3 categorizations : get /:id" do
      before do
        @categories = %w(Energy Finance Poverty).map do |name|
          create_category(:name => name)
        end
        @categories.each do |category|
          create_categorization(
            :category_id => category.id,
            :source_id   => @id
          )
        end
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end

      use "successful GET source with :id"

      test "body should have correct category_ids" do
        actual = parsed_response_body["category_ids"]
        @categories.each do |category|
          assert_include category.id, actual
        end
      end
      
      test "body should have correct category_names" do
        actual = parsed_response_body["category_names"]
        expected = %w(Finance Energy Poverty)
        assert_equal expected.sort, actual.sort
      end
    end

    context "#{role} API key : 2 comments : get /:id" do
      before do
        @comments = [
          create_comment({
            :text      => "Comment 1",
            :source_id => @id,
          }),
          create_comment({
            :text      => "Comment 2",
            :source_id => @id,
          })
        ]
        get "/#{@id}", :api_key => primary_api_key_for(role)
      end
      
      use "successful GET source with :id"
      
      test "body should have correct comment_details" do
        comment_details = parsed_response_body["comment_details"]
        @comments.each do |comment|
          expected = {
            "href" => "/comments/#{comment.id}",
            "text" => comment.text,
            "user" => {
              "name" => "Normal User",
              "href" => "/users/#{@normal_user.id}"
            }
          }
          assert_include expected, comment_details
        end
      end
    end

  end

end
