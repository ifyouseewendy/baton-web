class Step
  include Mongoid::Document

  # References
  belongs_to :task

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String
end
