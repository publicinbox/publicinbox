var mainApp = angular.module('publicInboxApp', ['ngSanitize']);

var mainController = mainApp.controller('MainCtrl', ['$scope', function($scope) {

  $scope.heading = 'Public<wbr /><em>Inbox</em>';

}]);

var inboxController = mainApp.controller('InboxCtrl', ['$scope', '$http', function($scope, $http) {

  $http.get('/inbox').success(function(messages) {
    $scope.messages = messages;
  });

}]);

var outboxController = mainApp.controller('OutboxCtrl', ['$scope', '$http', function($scope, $http) {

  $http.get('/outbox').success(function(messages) {
    $scope.messages = messages;
  });

}]);
