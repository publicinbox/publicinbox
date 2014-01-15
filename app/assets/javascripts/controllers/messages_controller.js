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
      message.reply_to
    ].join(' '));
  };

  $scope.replyToMessage = function reply(message) {
    $scope.draft.recipient_email = message.reply_to;
    $scope.draft.subject = prepend('Re: ', message.subject);
    $scope.showSection('compose');
  };

  $scope.sendMessage = function(message) {
    $http.post('/messages', { message: message }).success(function(message) {
      $scope.displayNotice('Message successfully sent.');
      $scope.outbox.unshift(message);
      $scope.showSection('outbox');
    });
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
