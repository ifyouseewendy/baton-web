class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # Concerns
  prepend StatusCheck

  # References
  has_many :stages, dependent: :destroy
  belongs_to :jingdong_recipe

  # Fields
  enum :env,    [:test, :online] # :test by default
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String
  field :recipe,      :type => Symbol
  field :category,    :type => String

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
