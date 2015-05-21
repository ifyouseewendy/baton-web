class Step
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  # References
  belongs_to :task

  # Fields
  enum :status, [:undone, :done] # :undone by default

  field :name,        :type => String
  field :description, :type => String
  field :job_id,      :type => String
  field :result,      :type => Hash

  # Files
  #
  # st.files << File.open('a.txt')  # => No support on << operation
  # st.files += File.open('a.txt')  # => Right
  # st.save!
  mount_uploaders :files, FileUploader

  def stage
    task.stage
  end

  def project
    stage.project
  end

  def recipe
    project.recipe
  end

  def run(args)
    begin
      job = "#{recipe.capitalize}Job::Step#{job_id}".constantize.new
      data = job.run args.merge({project_id: project.id.to_s})

      self.update_attribute(:result, data)
      self.done! if data[:status] == :succeed
    rescue => e
      self.update_attribute(:result, {status: :failed, message: e.message} )
    end
  end

  def file_list_date
    return Date.today.to_s if result.blank?

    result[:date]
  end

end
