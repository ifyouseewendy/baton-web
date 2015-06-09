# Learn more: http://github.com/javan/whenever

set :output, "log/schedule.log"

every :day, :at => '12:20am' do
  runner "XiaojinJob.new.check_transfer_detail"
end
