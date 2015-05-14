class Project
  include Mongoid::Document
  include Mongoid::Enum

  # References
  has_many :stages

  # Fields
  enum :env,    [:test, :online] # :test by default
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String

  # Validations
  validates :name, presence: true, uniqueness: true


  def tasks
    stages.flat_map(&:tasks)
  end

  def steps
    stages.flat_map(&:steps)
  end

  def check_status
    self.done! if stages.all?(&:done?)
  end
end
