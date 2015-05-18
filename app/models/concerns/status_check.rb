# Overwrites done? and done! predication which Mongoid::Enum provides
module StatusCheck
  def done?
    self.status == :done ? true : check_status!
  end

  def done!
    self.update_attribute(:status, :done)
    steps.map(&:done!)
  end

  private

    def check_status!
      return false unless steps.all?(&:done?)
      self.update_attribute(:status, :done)
    end

end
