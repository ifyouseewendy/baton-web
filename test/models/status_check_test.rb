module StatusCheckTest
  def test_customized_done?
    assert_equal :undone, @subject.status
    refute  @subject.done?

    @subject.steps.each{|st| st.done!}

    assert  @subject.done?
    assert_equal :done, @subject.status
  end

  def test_customized_done!
    assert_equal :undone, @subject.status
    step = @subject.steps.first
    assert_equal :undone, step.status

    @subject.done!

    assert_equal :done, step.status
    assert_equal :done, @subject.status
  end
end
