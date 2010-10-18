require File.expand_path('../../test_unit_helper', __FILE__)

class CategoryUnitTest < ModelTestCase

  shared "valid category" do
    test "should be valid" do
      assert_equal true, @category.valid?
    end
  end

  shared "invalid category" do
    test "should not be valid" do
      assert_equal false, @category.valid?
    end
  end

  shared "category.name can't be empty" do
    test "should have error on text" do
      @category.valid?
      assert_include :name, @category.errors.errors
      assert_include "can't be empty", @category.errors.errors[:name]
    end
  end

  # - - - - - - - - - -

  context "Category" do
    before do
      @valid_params = {
        :name => "Science & Technology"
      }
    end

    context "correct params" do
      before do
        @category = Category.new(@valid_params)
      end

      use "valid category"
    end

    context "missing name" do
      before do
        @category = Category.new(@valid_params.merge(:name => ""))
      end

      use "invalid category"
      use "category.name can't be empty"
    end

    context "slug" do
      context "new" do
        before do
          @category = Category.new(@valid_params)
        end

        after do
          @category.destroy
        end

        test "on validation, not set" do
          assert_equal true, @category.valid?
          assert_equal nil, @category.slug
        end

        test "on save, set based on title" do
          assert_equal true, @category.save
          assert_equal "science-technology", @category.slug
        end
      end

      context "create" do
        before do
          @category = Category.create(@valid_params)
        end

        after do
          @category.destroy
        end

        test "set based on title" do
          assert_equal "science-technology", @category.slug
        end
      end

      context "update" do
        before do
          @category = Category.new(@valid_params)
        end

        after do
          @category.destroy
        end

        test "unchanged after multiple saves" do
          @category.save
          assert_equal "science-technology", @category.slug
          @category.save
          assert_equal "science-technology", @category.slug
        end

        test "disallow duplicate slugs" do
          @category.slug = "in-use"
          @category.save
          @new_category = Category.new(@valid_params)
          @new_category.slug = "in-use"
          assert_equal false, @new_category.valid?
          expected = { :slug => ["has already been taken"] }
          assert_equal expected, @new_category.errors.errors
        end

        test "prevent duplicate slugs" do
          params = @valid_params.merge(:name => "Common")
          @category = Category.create(params)

          category_2 = Category.create!(params)
          assert_equal "common-2", category_2.slug

          category_3 = Category.create!(params)
          assert_equal "common-3", category_3.slug

          category_2.destroy
          category_3.destroy
        end
      end
    end

  end

end
