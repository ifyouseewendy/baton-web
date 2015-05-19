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
  field :platform,    :type => String

  # Validations
  validates :name, presence: true, uniqueness: true

  class << self
    def build_by(recipe)
      "#{recipe.capitalize}Recipe".constantize.instance.build
    end
  end

  def tasks
    stages.flat_map(&:tasks)
  end

  def steps
    stages.flat_map(&:steps)
  end

  def current_stage
    stages.detect(&:undone?)
  end

  def current_task
    current_stage.current_task
  end

  # No I18n temp
  def zh_env
    {test: '测试', online: '线上'}[env]
  end
end
