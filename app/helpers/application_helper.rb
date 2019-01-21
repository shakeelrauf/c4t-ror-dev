module ApplicationHelper

  def public_js_path(name)
    return "<script type='text/javascript' src='/js/#{name}'></script>".html_safe
  end

  def public_css_path(name)
    return "<link rel='stylesheet' type='text/css' href='/css/pages/#{name}'>".html_safe
  end

  def phone_number_display(val)
      return  if (val.length == 0)
      if (val.length >= 2)
        if (val[0] == '1')
          if (val[1] != '-')
              val = "1-" + val[1, val.length]
          end
          if (val.length >= 6 && val[5] != '-')
            val = val[0, 5] + "-" + val[5, val.length]
          end
          if (val.length >= 10 && val[9] != '-')
            val = val[0, 9] + "-" + val[9, val.length]
          end
        else
          if (val.length >= 6)

              val = val[0, 3] + "-" + val[3, val.length]
          end
          if (val.length >= 10 )
              val = val[0, 4] + val[4,3] + "-" + val[7, val.length]
          end
        end
      end
      return val
  end
end
