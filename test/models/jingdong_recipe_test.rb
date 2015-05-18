require 'test_helper'
require_relative 'recipe_test'

class JingdongRecipeTest < ActiveSupport::TestCase
  include RecipeTest

  def setup
    @subject = JingdongRecipe.instance
  end

  def teardown
    [Project, Stage, Task, Step].map(&:delete_all)
  end

  def test_build
    source = @subject.send(:read_source)

    @subject.build

    assert_equal 1, Project.count
    assert_equal source['stages'].count, Stage.count
    assert_equal source['stages'].map{|h| h['tasks'].count}.sum, Task.count
    assert_equal source['stages'].map{|h| h['tasks'].map{|hh| hh['steps'].count}.sum }.sum, Step.count
  end
end
