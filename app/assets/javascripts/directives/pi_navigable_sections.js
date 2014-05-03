function PINavigableSections($rootScope) {

  return {
    link: function(scope, element) {
      var sectionElements = element.find('section[id]');

      angular.forEach(sectionElements, function(sectionElement) {
        sectionElement = $(sectionElement);

        var id = sectionElement.attr('id');

        // TODO: Figure out why this doesn't work :(
        // sectionElement.attr('ng-show', "isActiveSection('" + id + "')");
      });

      // Handle clicks on any links to any section.
      $(document).on('click', 'a[href^="#"]', function(e) {
        var target = $(this).attr('href');

        // Prevent the browser from updating the address bar
        e.preventDefault();

        scope.app.section = target.substring(1);
        scope.nav.state = 'ready';
        scope.$apply();
      });

      scope.app.section = sectionElements.first().attr('id');
    }
  };

}
