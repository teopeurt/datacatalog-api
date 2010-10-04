require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class TagUnitTest < ModelTestCase

  shared "valid tag" do
    test "should be valid" do
      assert_equal true, @tag.valid?
    end
  end

  shared "invalid tag" do
    test "should not be valid" do
      assert_equal false, @tag.valid?
    end
  end

  shared "tag.name can't be empty" do
    test "should have error on text" do
      @tag.valid?
      assert_include :name, @tag.errors.errors
      assert_include "can't be empty", @tag.errors.errors[:name]
    end
  end

  # - - - - - - - - - -

  context "Tag" do
    before do
      @valid_params = {
        :name => "r&d"
      }
    end

    context "correct params" do
      before do
        @tag = Tag.new(@valid_params)
      end

      use "valid tag"
    end

    context "missing name" do
      before do
        @tag = Tag.new(@valid_params.merge(:name => ""))
      end

      use "invalid tag"
      use "tag.name can't be empty"
    end

    context "slug" do
      context "new" do
        before do
          @tag = Tag.new(@valid_params)
        end

        after do
          @tag.destroy
        end

        test "on validation, not set" do
          assert_equal true, @tag.valid?
          assert_equal nil, @tag.slug
        end

        test "on save, set based on title" do
          assert_equal true, @tag.save
          assert_equal "r-d", @tag.slug
        end
      end

      context "create" do
        before do
          @tag = Tag.create(@valid_params)
        end

        after do
          @tag.destroy
        end

        test "set based on title" do
          assert_equal "r-d", @tag.slug
        end
      end

      context "update" do
        before do
          @tag = Tag.new(@valid_params)
        end

        after do
          @tag.destroy
        end

        test "unchanged after multiple saves" do
          @tag.save
          assert_equal "r-d", @tag.slug
          @tag.save
          assert_equal "r-d", @tag.slug
        end

        test "disallow duplicate slugs" do
          @tag.slug = "in-use"
          @tag.save
          @new_tag = Tag.new(@valid_params)
          @new_tag.slug = "in-use"
          assert_equal false, @new_tag.valid?
          expected = { :slug => ["has already been taken"] }
          assert_equal expected, @new_tag.errors.errors
        end

        test "prevent duplicate slugs" do
          params = @valid_params.merge(:name => "Common")
          @tag = Tag.create(params)

          tag_2 = Tag.create!(params)
          assert_equal "common-2", tag_2.slug

          tag_3 = Tag.create!(params)
          assert_equal "common-3", tag_3.slug

          tag_2.destroy
          tag_3.destroy
        end
      end
    end

  end

end
