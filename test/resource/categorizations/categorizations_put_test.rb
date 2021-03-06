require File.expand_path('../../../test_resource_helper', __FILE__)

class CategorizationsPutTest < RequestTestCase

  def app; DataCatalog::Categorizations end

  before :all do
    @source = create_source
    @category = create_category(:name => "Category 1")
    @categorization = create_categorization(:source_id => @source.id, :category_id => @category.id)
    @categorization_count = Categorization.count
  end

  context "curator API key : put /:id with correct param" do
    before do
      put "/#{@categorization.id}", {
        :api_key => @curator_user.primary_api_key,
        :source_id => @source.id,
        :category_id => @category.id
      }
    end

    use "return 200 Ok"
    use "unchanged categorization count"

    test "field should be updated in database" do
      @category.name = "New Category"
      @category.save
      category = Category.find_by_id!(@categorization.category_id)
      assert_equal "New Category", category.name
    end
  end

end
