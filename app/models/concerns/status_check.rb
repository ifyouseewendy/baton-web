module StatusCheck
  # Customized done? method, overwriting the enum ones
  def done?
    self.status == :done ? true : check_status!
  end

  def fuck
    puts 'fuck'
  end

  private

    def check_status!
      return false unless steps.all?(&:done?)
      self.done!
    end

end
