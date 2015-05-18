class Recipe

  private

    def config_for(source)
      File.join(Rails.root, 'config', 'recipes', "#{source}.yml")
    end
end
