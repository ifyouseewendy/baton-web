class Project
  include Mongoid::Document
  include Mongoid::Enum

  # Concerns
  prepend StatusCheck

  # References
  has_many :stages
  belongs_to :jingdong_recipe

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

  def current_stage
    stages.detect(&:undone?)
  end
end
