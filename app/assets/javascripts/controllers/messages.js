publicInboxApp.controller('MessagesCtrl', ['$scope', '$http', function($scope, $http) {

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

  $scope.sendMessage = function sendMessage(message) {
    $scope.app.state = 'loading';

    var request = $http.post('/messages', { message: message })
      .success(function(message) {
        $scope.displayNotice('Message successfully sent.');
        $scope.outbox.unshift(message);
        $scope.showSection('outbox');
      });

    request['finally'](function() {
      $scope.app.state = 'ready';
    });
  };

  $scope.deleteMessage = function deleteMessage(message) {
    var confirmationPrompt = message.sender_email ?
      'Are you sure you want to delete this message?' :
      'Really delete your copy of this message (you cannot unsend it)?';

    if (confirm(confirmationPrompt)) {
      $scope.app.state = 'loading';

      var request = $http.delete('/messages/' + message.id)
        .success(function(response) {
          $scope.displayNotice(response);
          removeFromArray($scope.inbox, message);
          $scope.showSection('inbox');
        })
        .error(function(response) {
          $scope.displayNotice(response, 'error');
        });

      request['finally'](function() {
        $scope.app.state = 'ready';
      });
    }
  };

  $scope.draft = {};

  $scope.app.state = 'loading';

  $http.get('/messages').success(function(data) {
    $scope.inbox  = data.inbox;
    $scope.outbox = data.outbox;
    $scope.app.state = 'ready';
  });

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

/**
 * Removes an element from an array.
 *
 * @param {Array.<*>} array
 * @param {*} element
 */
function removeFromArray(array, element) {
  for (var len = array.length, i = len - 1; i >= 0; --i) {
    if (array[i] === element) {
      array.splice(i, 1);
      return;
    }
  }
}