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

  def main_attributes
    attributes = { 'ng-click' => 'hideNav()' }

    if logged_in?
      attributes.merge!({
        'ng-controller' => 'MessagesController',
        'pi-handle-mailtos' => 'true'
      })
    end

    attributes
  end
end
