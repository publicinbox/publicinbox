publicInboxApp.directive('piNav', function() {

  var sections = {};

  return {
    link: function(scope, element) {
      var navLinks = element.find('ul li a');

      var sections = {};
      angular.forEach(navLinks, function(link) {
        var target = $(link).attr('href');

        // Only apply this directive to links to sections
        if (target.charAt(0) !== '#') {
          return;
        }

        var section = $(target),
            id      = section.attr('id'),
            title   = section.attr('data-title');

        sections[id] = {
          title: title
        };
      });

      // This is a hack and tells me there's a fundamental problem
      // with what I'm doing here. I will think on this.
      scope.sections = angular.extend(sections, {
        message: { title: 'Message' }
      });

      navLinks.on('click', function(e) {
        var target = $(this).attr('href');

        // Only apply this directive to links to sections
        if (target && target.charAt(0) !== '#') {
          return;
        }

        // Prevent the browser from updating the address bar
        e.preventDefault();

        scope.showSection(target);
        scope.hideNav();
        scope.$apply();
      });

      var firstSection = navLinks.first().attr('href');
      scope.showSection(firstSection);
    }
  };

});
