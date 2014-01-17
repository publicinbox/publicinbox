publicInboxApp.controller('TestMessageCtrl', ['$scope', '$http', function($scope, $http) {

  $scope.sendTestMessage = function sendTestMessage(message) {
    var data = {
      'sender': message.from,
      'recipient': message.to,
      'subject': message.subject,
      'body-plain': message.body
    };

    angular.extend(data, JSON.parse(message.extra_data));

    $http.post('/messages/incoming', data)
      .success(function(response) {
        $scope.displayNotice('Success!');
      })
      .error(function(message) {
        $scope.displayNotice('Error: ' + message, 'error');
      });
  };

  $scope.test_message = {
    from: 'user@example.com',
    to: 'dan@publicinbox.net',
    subject: 'Testing',
    body: 'This is a test',
    extra_data: JSON.stringify({
      foo: 'foo',
      bar: {
        baz: [1, 2, 3]
      }
    })
  };

}]);
