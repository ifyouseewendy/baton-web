class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # Concerns
  prepend StatusCheck

  # References
  belongs_to  :stage
  has_many    :steps, dependent: :destroy

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String

  def current_step
    steps[steps.map(&:done?).index(false)]
  end

  def files
    steps.flat_map(&:files)
  end

end
