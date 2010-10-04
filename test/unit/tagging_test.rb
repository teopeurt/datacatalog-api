require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class TaggingUnitTest < ModelTestCase

  context "Source" do
    before do
      [Tagging, Tag, Source].each { |m| m.destroy_all }
      @source = create_source
      @user = create_user
    end

    after do
      @source.destroy
    end

    context "with no Taggings" do
      test "#taggings should be empty" do
        assert @source.taggings.empty?
      end
    end

    context "with 3 Taggings" do
      before do
        @tags = %w(interesting todo done).map do |name|
          create_tag(:name => name)
        end
        @taggings = @tags.map do |tag|
          create_tagging(
            :source_id => @source.id,
            :tag_id    => tag.id,
            :user_id   => @user.id
          )
        end
        @tags.each { |tag| tag.reload }
      end

      test "Source#taggings should be correct" do
        taggings = @source.taggings
        taggings.each do |tagging|
          assert_include tagging, @taggings
        end
      end

      test "Source#tags should be correct" do
        tags = @source.tags
        @tags.each do |tag|
          assert_include tag, tags
        end
      end

      test "Tag#sources should be correct" do
        @tags.each do |tag|
          assert_include @source, tag.sources
        end
      end
      
      test "Tag#source_count should be correct" do
        @tags.each do |tag|
          assert_equal 1, tag.source_count
        end
      end

      context "change Tagging source" do
        before do
          @tag = create_tag(:name => "Healthcare")
          @tagging = @taggings[0]
          @tagging.tag = @tag
          @tagging.save
          @tags.each { |c| c.reload }
          @tag.reload
        end
        
        test "new tag source_count should be correct" do
          assert_equal 1, @tag.source_count
        end
        
        test "changed tag should have decreased source_count" do
          assert_equal 0, @tags[0].source_count
          assert_equal 1, @tags[1].source_count
          assert_equal 1, @tags[2].source_count
        end
      end
      
    end
  end

end
