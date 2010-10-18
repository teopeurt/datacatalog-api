require File.expand_path('../../test_unit_helper', __FILE__)

class CategorizationUnitTest < ModelTestCase

  context "Source" do
    before do
      [Categorization, Category, Source].each { |m| m.destroy_all }
      @source = create_source
    end

    after do
      @source.destroy
    end

    context "with no Categorizations" do
      test "#categorizations should be empty" do
        assert @source.categorizations.empty?
      end
    end

    context "with 3 Categorizations" do
      before do
        @categories = %w(Energy Finance Poverty).map do |name|
          create_category(:name => name)
        end
        @categorizations = @categories.map do |category|
          create_categorization(
            :source_id   => @source.id,
            :category_id => category.id
          )
        end
        @categories.each { |category| category.reload }
      end

      test "Source#categorizations should be correct" do
        categorizations = @source.categorizations
        categorizations.each do |categorization|
          assert_include categorization, @categorizations
        end
      end

      test "Source#categories should be correct" do
        categories = @source.categories
        @categories.each do |category|
          assert_include category, categories
        end
      end

      test "Category#sources should be correct" do
        @categories.each do |category|
          assert_include @source, category.sources
        end
      end
      
      test "Category#source_count should be correct" do
        @categories.each do |category|
          assert_equal 1, category.source_count
        end
      end

      context "change Categorization source" do
        before do
          @category = create_category(:name => "Healthcare")
          @categorization = @categorizations[0]
          @categorization.category = @category
          @categorization.save
          @categories.each { |c| c.reload }
          @category.reload
        end
        
        test "new category source_count should be correct" do
          assert_equal 1, @category.source_count
        end
        
        test "changed category should have decreased source_count" do
          assert_equal 0, @categories[0].source_count
          assert_equal 1, @categories[1].source_count
          assert_equal 1, @categories[2].source_count
        end
      end
      
    end
  end

end
