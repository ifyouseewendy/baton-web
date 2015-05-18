class JingdongRecipe
  include Recipe

  has_many :projects

  def build
    source = read_source

    project = self.projects.create(name: source['name'], description: source['description'])
    source['stages'].each do |stage_source|
      stage = project.stages.create(name: stage_source['name'], description: stage_source['description'])
      stage_source['tasks'].try(:each) do |task_source|
        task = stage.tasks.create(name: task_source['name'], description: task_source['description'])
        task_source['steps'].try(:each) do |step_source|
          task.steps.create(name: step_source['name'], description: step_source['description'])
        end
      end
    end
  end

  private

    def read_source
      YAML.load File.read( config_for(:jingdong)  )
    end
end
