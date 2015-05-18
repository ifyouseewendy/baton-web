module StatusCheckTest
  def test_customized_done?
    assert_equal :undone, @subject.status
    refute  @subject.done?

    @subject.steps.each{|st| st.done!}

    assert  @subject.done?
    assert_equal :done, @subject.status
  end
end
