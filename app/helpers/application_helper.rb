module ApplicationHelper
  def nav_menu
    render(:partial => 'partials/navigation')
  end

  def site_footer
    render(:partial => 'partials/site_footer')
  end
end
