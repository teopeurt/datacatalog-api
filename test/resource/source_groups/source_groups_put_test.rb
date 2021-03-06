require File.expand_path('../../../test_resource_helper', __FILE__)

class SourceGroupsPutTest < RequestTestCase

  def app; DataCatalog::SourceGroups end

  before do
    @source_group = create_source_group({
      :title     => "Original Source Group",
    })
    @source_group_count = SourceGroup.count
  end

  after do
    @source_group.destroy
  end

  context "basic API key : put /:id with correct param" do
    before do
      put "/#{@source_group.id}", {
        :api_key => @curator_user.primary_api_key,
        :title   => "New Source Group"
      }
    end

    use "return 200 Ok"
    use "unchanged source group count"

    test "source group in database should be correct" do
      @source_group.reload
      assert_equal "New Source Group", @source_group.title
    end

    doc_properties %w(
      title
      slug
      description
      id
      updated_at
      created_at
    )

  end

end
