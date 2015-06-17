# Learn more: http://github.com/javan/whenever

set :output, "log/schedule.log"

every :day, :at => '02:00am' do
  runner "XiaojinJob.new.check_transfer_detail"
end
