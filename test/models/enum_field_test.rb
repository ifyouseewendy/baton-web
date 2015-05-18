module EnumFieldTest
  def test_default_status
    assert_equal :undone, @subject.status
  end

  def test_status_predict
    assert @subject.undone?
    refute @subject.done?
  end

  def test_status_set
    assert_equal :undone, @subject.status
    @subject.done!
    assert_equal :done, @subject.status
  end

end
