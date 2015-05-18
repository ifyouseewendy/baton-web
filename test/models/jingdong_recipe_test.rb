require 'test_helper'
require_relative 'recipe_test'

class JingdongRecipeTest < ActiveSupport::TestCase
  include RecipeTest

  def setup
    @subject = JingdongRecipe.instance
  end

end
