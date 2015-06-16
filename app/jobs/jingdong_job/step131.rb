require 'charlock_holmes'

module JingdongJob
  class Step131
    # 批量生成产品合同
    def run(step, args)
      begin
        code, count, index_length = args.values_at(
          :product_start_code,
          :product_count,
          :product_index_length
        )

        if args[:env] == :online
          template = step.stage.files.detect{|af| Pathname(af.file.current_path).extname == '.html' }.file.current_path
          content = read_utf8_content(template)
        else
          content = Rails.root.join('samples').join('guangjiaosuo').join('产品合同模板.html').read
        end

        bourse = get_bourse(step)

        output_dir = Rails.root.join('tmp').join("#{bourse}_contract_#{step.project.get_serial}")
        FileUtils.mkdir_p output_dir

        (1..count.to_i).each do |idx|
          period = prefill_zero(idx, index_length || 2)

          output_file = File.join(output_dir, "#{bourse}_#{bourse}#{code}_contract.html")
          File.open(output_file, 'w:GBK:UTF-8') do |wf|
            wf.write content\
                      .gsub('__contract_index__', "#{code}001")\
                      .gsub('__period_index__', period)\
                      .gsub('__product_code__', code.to_s)

            code.next!
          end

          puts ">> Generate file: #{output_file}"
        end

        Dir.chdir(output_dir)
        zip_name = "#{bourse}_contract_#{step.project.get_serial}.zip"
        `7z a #{zip_name} *`
        Dir.chdir(Rails.root)

        step.add_file(output_dir.join(zip_name), step.platform, override: true)

        output_dir.rmtree

        {
          status: :succeed,
          type: :file_list,
          stat: step.file_names.zip(step.file_urls)
        }
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
        {
          status: :failed,
          message: e.message
        }
      end
    end

    private

      def read_utf8_content(file)
        content = File.read(file)
        detection = CharlockHolmes::EncodingDetector.detect(content)
        CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'
      end

      def prefill_zero(num, length)
        res = num.to_s
        res = ([0]*(length.to_i - res.length) + res.to_s.chars).join if num.to_s.length < length.to_i
        return res
      end

      def get_bourse(step)
        bourse = step.project.bourse
        bourse = :kaitong if bourse == :guangjiaosuo # Incompatible name for Jingdong
        bourse
      end


  end
end
