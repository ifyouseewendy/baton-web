class FileAgent

  class NameMapping
    class << self
      def parse(platform, fn)
        "::FileAgent::#{platform.capitalize}NameMapping".constantize
          .parse(fn) rescue fn
      end
    end
  end

end
