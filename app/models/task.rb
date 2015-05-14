class Task
  include Mongoid::Document

  # References
  belongs_to  :stage
  has_many    :steps

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String

  def check_status
    self.done! if steps.all?(&:done?)
  end
end
