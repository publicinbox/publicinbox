publicInboxApp.controller('MessagesCtrl', ['$scope', '$http', function($scope, $http) {

  $scope.showMessage = function showMessage(message, e) {
    e.preventDefault();

    $scope.message = angular.extend({}, message, {
      section: message.sender_email ? 'inbox' : 'outbox'
    });

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
    if (!message.body) {
      if (!confirm('Really send a message without a body?')) {
        return;
      }

    } else if (!message.subject) {
      if (!confirm('Really send a message without a subject?')) {
        return;
      }
    }

    $scope.app.state = 'loading';

    var request = $http.post('/messages', { message: message })
      .success(function(message) {
        $scope.displayNotice('Message successfully sent.');
        $scope.outbox.unshift(message);
        $scope.showSection('outbox');
      })
      .error(function(response) {
        $scope.displayNotice(response, 'error');
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

      var section = message.sender_email ? 'inbox' : 'outbox';

      var request = $http.delete('/messages/' + message.id)
        .success(function(response) {
          $scope.displayNotice(response);
          $scope.removeMessage(message);
          $scope.showSection(section);
        })
        .error(function(response) {
          $scope.displayNotice(response, 'error');
        });

      request['finally'](function() {
        $scope.app.state = 'ready';
      });
    }
  };

  $scope.removeMessage = function removeMessage(message) {
    var isSameMessage = function(m) {
      return m.id === message.id;
    };

    // Remove from both inbox and outbox, to account for scenario where the user
    // sent him-/herself a message.
    removeFromArray($scope.inbox, isSameMessage);
    removeFromArray($scope.outbox, isSameMessage);
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
function removeFromArray(array, predicate) {
  predicate = createPredicate(predicate);
  for (var len = array.length, i = len - 1; i >= 0; --i) {
    if (predicate(array[i])) {
      array.splice(i, 1);
    }
  }
}

/**
 * Takes a value and returns a predicate (function) that checks whether its
 * argument is equal to that value. Or, if passed a function, simply returns it.
 *
 * @param {*} predicate
 * @returns {function(*):boolean}
 */
function createPredicate(predicate) {
  if (typeof predicate === 'function') {
    return function(x) { return !!predicate(x); };
  }

  if (isNaN(predicate)) {
    return function(x) { return isNaN(x); };
  }

  return function(x) { return x === predicate; };
}
