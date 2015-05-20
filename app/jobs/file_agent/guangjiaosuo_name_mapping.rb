class FileAgent

  class GuangjiaosuoNameMapping
    class << self

      # "guangjiaosuo_产品信息表_20150507.xlsx" -> "产品信息表"
      def parse(fn)
        (Pathname(fn).basename.to_s.split("_")[1] rescue nil) || fn
      end

    end
  end
end
