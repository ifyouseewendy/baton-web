class DataController < ApplicationController
  def index
    platform = Platform.where(name: 'xiaojin').first
    project  = platform.projects.where(name: 'alpha').first

    @daily_stats = {}
    project.hourly_stats.asc(:date).asc(:hour).each do |hs|
      @daily_stats[hs.date] ||= {order_count: 0, share_count: 0}
      @daily_stats[hs.date][:order_count] += hs.order_count
      @daily_stats[hs.date][:share_count] += hs.share_count
    end
  end

  def get_hourly
    platform = Platform.where(name: 'xiaojin').first
    project  = platform.projects.where(name: 'alpha').first

    hours, order_count, share_count = [], [], []
    project.hourly_stats.asc(:date).asc(:hour).each do |hs|
      hours       << "#{hs.date} #{hs.hour}"
      order_count << hs.order_count
      share_count << hs.share_count
    end

    render json: \
    {
      status: 'succeed',
      data:{
        platform: platform.name,
        hours: hours,
        series: [
          {
            name: "订单数量",
            data: order_count
          },
          {
            name: "销售额",
            data: share_count
          }
        ]
      }
    }
  end
end
