module JingdongJob
  class Step223
    # 生成《客户明细销售表》
    def run(step, args)
      begin
        @file = step.stage.tasks[0].files.first.try(:file) # 京东上传的《交易确认文件》
        @pa = Pathname.new @file.try(:current_path)

        output = @pa.dirname.join( "#{step.bourse}_客户明细销售表_#{Date.today.to_s.gsub('-','')}.csv" )

        File.open(output, 'w:GBK') do |wf|

          wf.puts "客户姓名,客户全称,机构标志,证件类别,证件编号,证件地址,性别,电话,邮政编码,联系地址,传真,股权代码,股权数量,股权性质,上市日期,持仓均价,手机,风险级别,股权代码,营业部"

          File.open(@pa, 'r:GBK') do |rf|
            rf.each_with_index do |line, i|
              next if i <= 1
              next if line.empty?

              columns = line.split("|")

              platform = '京东平台'
              code = columns[1][-6..-1]
              wf.puts [columns[3], nil, 0, 0, columns[4], platform, nil, columns[5], '100000', platform, nil, code, columns[7].to_i, nil, nil, 1, columns[5], 1, code, '2002'].map(&:to_s).map{|str| str.encode(Encoding::GBK)}.join(",")
            end
          end
        end

        step.add_file(output, step.bourse, override: true)

        {
          status: :succeed,
          type: :file_list,
          stat: step.file_names.zip(step.file_urls)
        }
      rescue => e
        {
          status: :failed,
          message: e.message
        }
      end
    end

  end
end
