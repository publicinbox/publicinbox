var publicInboxApp = angular.module('publicInboxApp', ['ngSanitize']);

publicInboxApp.directive('piTabs', function() {

  return {
    link: function(scope, element) {
      var navLinks = element.find('ul li a'),
          sections = $(element.attr('data-sections'));

      function showSection(section) {
        // Hide all but the target section
        sections.hide();
        section.show();

        // Update the page title
        scope.title = section.attr('data-title');
        scope.$apply();
      }

      navLinks.on('click', function(e) {
        var href   = $(this).attr('href'),
            target = $(href);

        // Only apply this directive to links to sections
        if (href.charAt(0) !== '#') {
          return;
        }

        // Prevent the browser from updating the address bar
        e.preventDefault();

        showSection(target);
      });

      // Show the first action on page load
      showSection(sections.first());
    }
  };

});

var mainController = publicInboxApp.controller('MainCtrl', ['$scope', function($scope) {
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
  };

  $scope.closeMessage = function closeMessage() {
    $scope.message = null;
  };

}]);
