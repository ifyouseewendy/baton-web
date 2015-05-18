class Task
  include Mongoid::Document
  include Mongoid::Enum

  # Concerns
  prepend StatusCheck

  # References
  belongs_to  :stage
  has_many    :steps

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String

end
