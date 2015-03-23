class DataController < ApplicationController
  def index
  end

  def get_hourly
    render json: \
    {
      status: 'succeed',
      data:{
        hours: [
          '2015-01-01 01', '2015-01-01 02',
          '2015-01-01 03', '2015-01-01 05',
          '2015-01-01 05', '2015-01-01 06',
        ],
        series: [
          {
            name: 'xiaojin',
            data: [1,2,3,4,5,6]
          }
        ]
      }
    }
  end
end
