require File.expand_path('../../../test_resource_helper', __FILE__)

class DocumentsGetAllTest < RequestTestCase

  def app; DataCatalog::Documents end

  context "0 documents" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 documents" do
    before do
      @documents = 3.times.map do |n|
        source = create_source
        create_document(
          :text      => "Document #{n}",
          :source_id => source.id
        )
      end
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @normal_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct text" do
        actual = (0 ... 3).map { |n| @members[n]["text"] }
        3.times { |n| assert_include "Document #{n}", actual }
      end
    end
  end

end
