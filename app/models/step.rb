class Step
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # References
  belongs_to :task

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String
  field :job_id,      :type => String

  def stage
    task.stage
  end

  def project
    stage.project
  end

  def run(args)
    "#{project.recipe.capitalize}Job::Step#{job_id}".constantize.new.run(args)
  end
end
