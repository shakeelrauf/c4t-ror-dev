module ApplicationHelper

  def public_js_path(name)
    return "<script type='text/javascript' src='/js/#{name}'></script>".html_safe
  end
end
