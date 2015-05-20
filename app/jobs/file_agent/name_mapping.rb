class FileAgent

  class NameMapping
    class << self
      def parse(platform, fn)
        "::FileAgent::#{platform.capitalize}NameMapping".constantize
          .parse(fn.force_encoding(Encoding::UTF_8) ) rescue fn
      end
    end
  end

end
