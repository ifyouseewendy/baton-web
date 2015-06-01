class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # Concerns
  prepend StatusCheck

  # References
  has_many :stages, dependent: :destroy
  belongs_to :jingdong_recipe
  belongs_to :normal_recipe

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

  # Constants
  CATEGORY = %w(私募债 理财产品 收益权转让)

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
    stages[stages.map(&:done?).index(false)]
  end

  def current_task
    current_stage.current_task
  end

  # No I18n temp
  def zh_env
    {test: '测试', online: '线上'}[env]
  end

  def category_index
    CATEGORY.index(category) + 1
  end

  def files
    stages.flat_map(&:files)
  end

  def filenames
    files.map(&:file_identifier)
  end

end
