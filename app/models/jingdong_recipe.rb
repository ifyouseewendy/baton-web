class JingdongRecipe
  include Recipe

  def build
    source = YAML.load File.read( config_for(:jingdong)  )

    project = Project.create(name: source['name'], description: source['description'])
    source['stages'].each do |stage_source|
      stage = project.stages.create(name: stage_source['name'], description: stage_source['description'])
      stage_source['tasks'].each do |task_source|
        task = stage.tasks.create(name: task_source['name'], description: task_source['description'])
        task_source['steps'].each do |step_source|
          task.steps.create(name: step_source['name'], description: step_source['description'])
        end
      end
    end
  end
end
