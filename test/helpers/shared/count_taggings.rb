class RequestTestCase

  shared "incremented tagging count" do
    test "should increment tagging count" do
      assert_equal @tagging_count + 1, Tagging.count
    end
  end

  shared "unchanged tagging count" do
    test "should not change tagging count" do
      assert_equal @tagging_count, Tagging.count
    end
  end

  shared "decremented tagging count" do
    test "should decrement tagging count" do
      assert_equal @tagging_count - 1, Tagging.count
    end
  end

end
