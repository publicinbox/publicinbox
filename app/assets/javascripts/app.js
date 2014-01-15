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
        scope.$apply();
      });

      var firstSection = navLinks.first().attr('href');
      scope.showSection(firstSection);
    }
  };

});

var mainController = publicInboxApp.controller('MainCtrl', ['$scope', function($scope) {

  $scope.showSection = function showSection(sectionName, title) {
    if (sectionName.charAt(0) === '#') {
      sectionName = sectionName.substring(1);
    }

    $scope.title = title || $scope.sections[sectionName].title;
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

    $scope.message = message;

    $scope.showSection('message', [
      'Message',
      message.sender_email ? 'from' : 'to',
      message.sender_email || message.recipient_email
    ].join(' '));
  };

  $scope.replyToMessage = function reply(message) {
    $scope.draft.email = message.display_email;
    $scope.draft.subject = prepend('Re: ', message.subject);
    $scope.showSection('compose');
  };

  $scope.draft = {};

}]);

/**
 * Prepends `prefix` to `string`, *if* not the string does not already begin
 * with that prefix.
 *
 * @param {string} prefix
 * @param {string} string
 * @returns {string}
 */
function prepend(prefix, string) {
  if (string.substring(0, prefix.length) !== prefix) {
    string = prefix + string;
  }
  return string;
}
