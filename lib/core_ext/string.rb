class String
  def to_pinyin(options = {splitter: ''})
    Pinyin.t(self, options)
  end
end
