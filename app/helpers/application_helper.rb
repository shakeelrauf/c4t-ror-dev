module ApplicationHelper

  def public_js_path(name)
    return "<script type='text/javascript' src='/js/#{name}'></script>".html_safe
  end

  def public_css_path(name)
    return "<link rel='stylesheet' type='text/css' href='/css/pages/#{name}'>".html_safe
  end
end
