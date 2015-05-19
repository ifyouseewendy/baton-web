require 'test_helper'
require_relative 'recipe_test'

class NormalRecipeTest < ActiveSupport::TestCase
  include RecipeTest

  def setup
    @subject = NormalRecipe.instance
  end

  def teardown
    [Project, Stage, Task, Step].map(&:delete_all)
  end

  def test_build
    source = @subject.send(:read_source)

    @subject.build

    assert_equal 1, Project.count
    assert_equal source['stages'].count, Stage.count
    assert_equal source['stages'].map{|h| h['tasks'].count rescue 0 }.sum, Task.count
    assert_equal source['stages'].map{|h| h['tasks'].map{|hh| hh['steps'].count rescue 0}.sum rescue 0 }.sum, Step.count

    assert_equal 1, @subject.projects.count
    assert_equal Project.first, @subject.projects.first
  end
end
