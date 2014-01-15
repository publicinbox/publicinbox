var publicInboxApp = angular.module('publicInboxApp', ['ngSanitize']);

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

      scope.sections = angular.extend(sections, {
        message: {
          title: function() {
            return 'Message from ' + scope.message.display_email;
          }
        }
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
        scope.$apply();
      });

      var firstSection = navLinks.first().attr('href');
      scope.showSection(firstSection);
    }
  };

});

var mainController = publicInboxApp.controller('MainCtrl', ['$scope', function($scope) {

  $scope.showSection = function showSection(sectionName) {
    if (sectionName.charAt(0) === '#') {
      sectionName = sectionName.substring(1);
    }

    var title = $scope.sections[sectionName].title;
    $scope.title = typeof title === 'function' ? title() : title;
    $scope.activeSection = sectionName;
  };

  $scope.isActiveSection = function isActiveSection(sectionName) {
    return $scope.activeSection === sectionName;
  };

  $scope.activeSection = 'inbox';

}]);

var messagesController = publicInboxApp.controller('MessagesCtrl', ['$scope', '$http', function($scope, $http) {

  $http.get('/messages').success(function(data) {
    $scope.inbox  = data.inbox;
    $scope.outbox = data.outbox;
  });

  $scope.showMessage = function showMessage(message, e) {
    e.preventDefault();

    $scope.message = angular.extend({}, message, {
      preposition: message.sender_email ? 'from' : 'to',
      display_email: message.sender_email || message.recipient_email
    });

    $scope.showSection('message');
  };

}]);
