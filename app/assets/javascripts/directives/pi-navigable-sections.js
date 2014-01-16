publicInboxApp.directive('piNavigableSections', function() {

  var sections = {};

  return {
    link: function(scope, element) {
      var sectionElements = element.find('section[id]');

      angular.forEach(sectionElements, function(sectionElement) {
        sectionElement = $(sectionElement);

        var id    = sectionElement.attr('id'),
            title = sectionElement.attr('data-title');

        // TODO: Figure out why this doesn't work :(
        // sectionElement.attr('ng-show', "isActiveSection('" + id + "')");

        sections[id] = { title: title };
      });

      // This probably shouldn't be a singleton like this?
      // For now I think it's OK.
      scope.sections = sections;

      // Handle clicks on any links to any section.
      $(document).on('click', 'a[href^="#"]', function(e) {
        var target = $(this).attr('href');

        // Prevent the browser from updating the address bar
        e.preventDefault();

        scope.showSection(target);
        scope.hideNav();
        scope.$apply();
      });

      scope.showSection(sectionElements.first().attr('id'));
      scope.$apply();
    }
  };

});
