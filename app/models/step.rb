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
  field :result,      :type => Hash

  def stage
    task.stage
  end

  def project
    stage.project
  end

  def run(args)
    begin
      job = "#{project.recipe.capitalize}Job::Step#{job_id}".constantize.new
      data = job.run(args)

      self.update_attribute(:result, data)
      self.done! if data[:status] == :succeed
    rescue => e
      self.update_attribute(:result, {status: :failed, message: e.message} )
    end
  end
end
