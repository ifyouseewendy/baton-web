module RecipeTest
  def test_singlularity
    assert_equal 1, @subject.class.count
    assert_raise RuntimeError, "Singleton class" do
      @subject.class.create
    end
  end
end
