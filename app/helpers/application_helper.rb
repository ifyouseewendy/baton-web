module ApplicationHelper

  def html_format(result)
    return nil if result.blank?

    ret = {status: result[:status]}

    if result[:status] == :succeed
      data = result[:stat]
      if result[:type] == :file_list
        ret[:html] = \
          content_tag(
            :ul,
            -> {
              data.reduce('') do |str, ar|
                str << \
                  content_tag(:li) do
                    link_to(ar[0], ar[1])
                  end
              end
            }.call,
            nil,
            false
          )
      elsif result[:type] == :message_list
        ret[:html] = \
          content_tag(
            :ul,
            -> {
              data.reduce('') do |str, ele|
                str << content_tag(:li, ele)
              end
            }.call,
            nil,
            false
          )
      end
    else
      ret[:html] = content_tag(:p, result[:message], class: 'error-message')
    end

    ret
  end

end
