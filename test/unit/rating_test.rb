# TODO: use get_fake_mongo_object_id instead of Mongo::ObjectID.new.to_s
require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class RatingUnitTest < ModelTestCase
  
  shared "valid rating" do
    test "should be valid" do
      assert_equal true, @rating.valid?
    end
  end

  shared "invalid rating" do
    test "should not be valid" do
      assert_equal false, @rating.valid?
    end
  end
  
  shared "user_id can't be empty" do
    test "should have error on user_id" do
      @rating.valid?
      assert_include :user_id, @rating.errors.errors
      assert_include "can't be empty", @rating.errors.errors[:user_id]
    end
  end

  shared "source_id can't be empty" do
    test "should have error on source_id" do
      @rating.valid?
      assert_include :source_id, @rating.errors.errors
      assert_include "can't be empty", @rating.errors.errors[:source_id]
    end
  end

  shared "comment_id can't be empty" do
    test "should have error on user_id" do
      @rating.valid?
      assert_include :comment_id, @rating.errors.errors
      assert_include "can't be empty", @rating.errors.errors[:comment_id]
    end
  end

  shared "value not between 0 and 1" do
    test "value should be between 0 and 1" do
      @rating.valid?
      assert_include :value, @rating.errors.errors
      assert_include "must be 0 or 1", @rating.errors.errors[:value]
    end
  end
  
  shared "value not between 1 and 5" do
    test "value should be between 1 and 5" do
      @rating.valid?
      assert_include :value, @rating.errors.errors
      assert_include "must be between 1 and 5", @rating.errors.errors[:value]
    end
  end
  
  shared "text must be empty" do
    test "text should be empty" do
      @rating.valid?
      assert_include :text, @rating.errors.errors
      assert_include "must be empty", @rating.errors.errors[:text]
    end
  end
  
  # - - - - - - - - - -
  
  context "Rating.new : source" do
    before do
      @valid_params = {
        :kind      => "source",
        :value     => 4,
        :text      => "An explanation",
        :user_id   => Mongo::ObjectID.new.to_s,
        :source_id => Mongo::ObjectID.new.to_s
      }
    end
    
    context "correct params" do
      before do
        @rating = Rating.new @valid_params
      end
      
      use "valid rating"
    end

    context "invalid value" do
      before do
        @rating = Rating.new @valid_params.merge(:value => 6)
      end
  
      use "invalid rating"
      use "value not between 1 and 5"
    end

    context "missing user_id" do
      before do
        @rating = Rating.new @valid_params.merge(:user_id => "")
      end
      
      use "invalid rating"
      use "user_id can't be empty"
    end

    context "missing source_id" do
      before do
        @rating = Rating.new @valid_params.merge(:source_id => "")
      end
      
      use "invalid rating"
      use "source_id can't be empty"
    end
  end
  
  context "Rating.new : comment" do
    before do
      @valid_params = {
        :kind       => "comment",
        :value      => 1,
        :user_id    => Mongo::ObjectID.new.to_s,
        :comment_id => Mongo::ObjectID.new.to_s
      }
    end
    
    context "correct params" do
      before do
        @rating = Rating.new @valid_params
      end
  
      use "valid rating"
    end
  
    context "invalid value" do
      before do
        @rating = Rating.new @valid_params.merge(:value => 2)
      end
  
      use "invalid rating"
      use "value not between 0 and 1"
    end
  
    context "missing user_id" do
      before do
        @rating = Rating.new @valid_params.merge(:user_id => "")
      end
  
      use "invalid rating"
      use "user_id can't be empty"
    end
  
    context "missing comment_id" do
      before do
        @rating = Rating.new @valid_params.merge(:comment_id => "")
      end
      
      use "invalid rating"
      use "comment_id can't be empty"
    end
    
    context "extra param : text" do
      before do
        @rating = Rating.new @valid_params.merge(:text => "explanation")
      end
      
      use "invalid rating"
      use "text must be empty"
    end
  end

end