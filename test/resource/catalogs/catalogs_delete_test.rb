require File.expand_path('../../../test_resource_helper', __FILE__)

class CatalogsDeleteTest < RequestTestCase

  def app; DataCatalog::Catalogs end

  before do
    @catalog = create_catalog
    @catalog_count = Catalog.count
  end

  %w(curator).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@catalog.id}", :api_key => primary_api_key_for(role)
      end

      use "return 204 No Content"

      test "catalog counts should decrement" do
        new_catalog_count = Catalog.count
        assert_equal @catalog_count - 1, new_catalog_count
      end

      test "catalog should be deleted in database" do
        assert_equal nil, Catalog.find_by_id(@catalog.id)
      end
    end
  end

end
