require File.expand_path('../../../test_resource_helper', __FILE__)

class DocumentsGetFilterTest < RequestTestCase

  def app; DataCatalog::Documents end

  context "6 documents" do
    before do
      @sources = (0 ... 3).map { |n| create_source }
      @documents = 6.times.map do |n|
        k = n % 3
        create_document(
          :text      => "Document #{k}",
          :user_id   => @normal_user.id,
          :source_id => @sources[k].id
        )
      end
    end

    after do
      @documents.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
    end

    context "normal API key : get / where text is 'Document 2'" do
      before do
        get "/",
          :api_key => @normal_user.primary_api_key,
          :filter  => "text:'Document 2'"
        @members = parsed_response_body['members']
      end

      test "body should have 2 top level elements" do
        assert_equal 2, @members.length
      end

      test "each element should be correct" do
        @members.each do |element|
          assert_equal 'Document 2', element["text"]
          assert_equal @normal_user.id.to_s, element["user_id"]
          assert_equal @sources[2].id.to_s, element["source_id"]
        end
      end
    end
  end
end
