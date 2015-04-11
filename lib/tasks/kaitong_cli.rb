require 'thor'

class KaitongCli < Thor

  private

    def load_rails
      require File.expand_path('config/environment.rb')
    end
end
