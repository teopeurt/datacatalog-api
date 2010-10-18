require File.expand_path('../../../test_resource_helper', __FILE__)

class TagsPutTest < RequestTestCase

  def app; DataCatalog::Tags end

  before do
    @tag = create_tag(:name => "Original Tag")
    @tag_count = Tag.count
  end

  after do
    @tag.destroy
  end

  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@tag.id}", {
        :api_key => @admin_user.primary_api_key,
        :name    => "New Tag"
      }
    end

    use "return 200 Ok"
    use "unchanged tag count"

    test "name should be updated in database" do
      tag = Tag.find_by_id!(@tag.id)
      assert_equal "New Tag", tag.name
    end
  end

end
