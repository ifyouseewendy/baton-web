class Stage
  include Mongoid::Document
  include Mongoid::Enum

  # References
  belongs_to  :project
  has_many    :tasks

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String

  def steps
    tasks.flat_map(&:steps)
  end

  def check_status
    self.done! if tasks.all?(&:done?)
  end
end
