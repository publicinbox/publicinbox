module ApplicationHelper
  def partial(name)
    render(:partial => "partials/#{name}")
  end

  def nav_menu
    partial('navigation')
  end

  def site_footer
    partial('site_footer')
  end

  def site_about
    partial('about')
  end
end
