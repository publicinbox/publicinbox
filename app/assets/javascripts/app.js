var mainApp = angular.module('publicInboxApp', []);

var messagesController = mainApp.controller('MessagesCtrl', ['$scope', '$http', function($scope, $http) {

  $http.get('/messages').success(function(data) {
    $scope.inbox  = data.inbox;
    $scope.outbox = data.outbox;
  });

}]);
