var mainApp = angular.module('publicInboxApp', []);

var messagesController = mainApp.controller('MessagesCtrl', ['$scope', '$http', function($scope, $http) {

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
