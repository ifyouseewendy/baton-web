class DataController < ApplicationController
  def index
  end

  def get_hourly
    # platform = Platform.where(name: 'xiaojin').first
    # project  = platform.projects.where(name: 'alpha').first

    # hours, order_count, share_count = [], [], []
    # project.hourly_stats.asc(:date).asc(:hour).each do |hs|
    #   hours       << "#{hs.date} #{hs.hour}"
    #   order_count << hs.order_count
    #   share_count << hs.share_count
    # end

    # render json: \
    # {
    #   status: 'succeed',
    #   data:{
    #     platform: platform.name,
    #     hours: hours,
    #     series: [
    #       {
    #         name: "订单数量",
    #         data: order_count
    #       },
    #       {
    #         name: "销售额",
    #         data: share_count
    #       }
    #     ]
    #   }
    # }

  render json: \
    {"status"=>"succeed","data"=>{"platform"=>"xiaojin","hours"=>["2015-03-20 10","2015-03-20 11","2015-03-20 12","2015-03-20 13","2015-03-20 14","2015-03-20 15","2015-03-20 16","2015-03-20 17","2015-03-20 18","2015-03-20 19","2015-03-20 20","2015-03-21 10","2015-03-21 11","2015-03-21 12","2015-03-21 13","2015-03-21 14","2015-03-21 15","2015-03-21 16","2015-03-21 17","2015-03-21 18","2015-03-21 19","2015-03-21 20"],"series"=>[{"name"=>"订单数量","data"=>[13,17,43,35,39,28,47,34,37,14,24,33,17,11,40,29,49,45,15,29,47,13]},{"name"=>"销售额","data"=>[38337,49177,128704,97359,118366,85097,131741,94220,105796,42818,74072,94350,52842,32391,119753,92097,142055,124500,42148,80348,147988,37589]}]}}
  end
end
