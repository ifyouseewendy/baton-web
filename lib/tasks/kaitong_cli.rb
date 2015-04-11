require 'thor'

class KaitongCli < Thor

  desc "hello NAME", "say hello to NAME"
  def hello(name)
    puts "Hello #{name}"
  end

  private

    def load_rails
      require File.expand_path('config/environment.rb')
    end
end
