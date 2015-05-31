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

        template = step.stage.files.detect{|af| Pathname(af.file.current_path).extname == '.html' }.file.current_path
        content = read_utf8_content(template)

        date = Date.today.to_s.gsub('-', '')
        output_dir = Rails.root.join('tmp').join("kaitong_contract_#{date}")
        FileUtils.mkdir_p output_dir

        (1..count.to_i).each do |idx|
          period = prefill_zero(idx, index_length || 2)

          output_file = File.join(output_dir, "kaitong_KAITONG#{code}_contract.html")
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
        zip_name = "kaitong_contract_#{date}.zip"
        `7z a #{zip_name} *`
        Dir.chdir(Rails.root)

        step.add_file(output_dir.join(zip_name), step.recipe, override: true)

        output_dir.rmtree

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


  end
end