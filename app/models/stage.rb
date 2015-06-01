class Stage
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # Concerns
  prepend StatusCheck

  # References
  belongs_to  :project
  has_many    :tasks, dependent: :destroy

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String

  def steps
    tasks.flat_map(&:steps)
  end

  def current_task
    tasks[tasks.map(&:done?).index(false)]
  end

  def progress
    "#{tasks.map(&:done?).index(false)} / #{tasks.to_a.count}"
  end

  def files
    tasks.flat_map(&:files)
  end

end
