publicInboxApp.controller('MessagesCtrl', ['$scope', '$http', function($scope, $http) {

  function sendRequest(method) {
    var requestArgs = Array.prototype.slice.call(arguments, 1);

    var callback = requestArgs.pop();

    var request = $http[method].apply($http, requestArgs)

    console.log('Calling $http.' + method + ' w/ args: ' + requestArgs.join(', '));

    request.success(callback);

    request.error(function(response) {
      $scope.displayNotice(response, 'error');
    });

    request['finally'](function() {
      $scope.app.state = 'ready';
    });

    $scope.app.state = 'loading';

    return request;
  }

  $scope.loadMessages = function loadMessages() {
    return sendRequest('get', '/messages', function(data) {
      $scope.user      = data.user;
      $scope.contacts  = data.contacts;
      $scope.messages  = data.messages;

      // This isn't really very Angular-y, but it seems logically to belong here
      // (in the messages controller) at least.
      var realtimeListener = new Pusher(data.subscription_key);
      var channel = realtimeListener.subscribe($scope.user.email);
      channel.bind('message', function(message) {
        $scope.addMessage(message);
        $scope.displayNotice('New message received from ' + message.sender_email + '!');
        $scope.$apply();
      });
    });
  };

  $scope.showMessage = function showMessage(message, e) {
    e.preventDefault();

    $http.put('/messages/' + message.unique_token)
      .success(function() {
        message.opened = true;
      })
      .error(function() {
        $scope.displayNotice('Failed to mark message as "opened" for some reason...');
      });

    $scope.message = message;

    $scope.showSection('message', message.subject || '[No subject]');
  };

  $scope.compose = function compose(recipient_email) {
    $scope.draft = {
      recipient_email: recipient_email
    };

    $scope.showSection('compose');
  };

  $scope.replyToMessage = function reply(message) {
    $scope.draft = {
      external_source_id: message.external_id,
      recipient_email: message.display_email,
      subject: prepend('Re: ', message.subject)
    };

    $scope.showSection('compose');
  };

  $scope.addCc = function addCc() {
    $scope.draft.include_cc = true;
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
      .success(function(response) {
        $scope.displayNotice('Message successfully sent.');
        $scope.addMessage(response);
        $scope.showSection('mailbox');

        // And now we should clear the draft so it isn't still there when the
        // user clicks on 'Compose' again.
        $scope.draft = {};
      })
      .error(function(response) {
        $scope.displayNotice(response, 'error');
      });

    request['finally'](function() {
      $scope.app.state = 'ready';
    });
  };

  $scope.deleteMessage = function deleteMessage(message) {
    var confirmationPrompt = message.type === 'incoming' ?
      'Are you sure you want to delete this message?' :
      'Really delete your copy of this message (you cannot unsend it)?';

    if (confirm(confirmationPrompt)) {
      sendRequest('delete', '/messages/' + message.unique_token, function(response) {
        $scope.displayNotice(response);
        $scope.removeMessage(message);
        $scope.showSection('mailbox');
      });
    }
  };

  $scope.batchRead = function batchRead() {
    var tokens = $scope.selection.map(function(message) {
      return message.unique_token;
    });

    sendRequest('put', '/batches', { batch: { messages: tokens } }, function() {
      angular.forEach($scope.selection, function(message) {
        message.opened = true;
      });

      $scope.displayNotice('Marked ' + tokens.length + ' messages as read.');
    });
  };

  $scope.batchDelete = function batchDelete() {
    var tokens = $scope.selection.map(function(message) {
      return message.unique_token;
    });

    sendRequest('delete', '/batches?messages=' + tokens.join(','), function() {
      angular.forEach($scope.selection, function(message) {
        $scope.removeMessage(message);
      });
      $scope.selection = [];

      $scope.displayNotice('Successfully deleted ' + tokens.length + ' messages.');
    });
  };

  $scope.addMessage = function addMessage(message) {
    $scope.messages.push(message);
    $scope.addContact(message.recipient_email);
  };

  $scope.removeMessage = function removeMessage(message) {
    removeFromArray($scope.messages, message);
  };

  $scope.addContact = function addContact(contact) {
    addToArray($scope.contacts, contact);
  };

  $scope.toggleSelection = function toggleSelection(message) {
    if (arrayContains($scope.selection, message)) {
      removeFromArray($scope.selection, message);
    } else {
      $scope.selection.push(message);
    }
  };

  $scope.messageIsSelected = function messageIsSelected(message) {
    return arrayContains($scope.selection, message);
  };

  $scope.editProfile = function editProfile() {
    $scope.user.editing = true;
  };

  $scope.draft = {};

  $scope.selection = [];

  $scope.loadMessages();

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
 * @param {*} predicate
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
 * Adds an element to an array (if not already present).
 *
 * @param {Array.<*>} array
 * @param {*} element
 */
function addToArray(array, element) {
  if (!arrayContains(array, element)) {
    array.push(element);
  }
}

/**
 * Checks whether an element exists in an array.
 *
 * @param {Array.<*>} array
 * @param {*} predicate
 */
function arrayContains(array, predicate) {
  predicate = createPredicate(predicate);
  for (var i = 0, len = array.length; i < len; ++i) {
    if (predicate(array[i])) {
      return true;
    }
  }
  return false;
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

  // Special case: NaN
  if (predicate !== predicate) {
    return function(x) { return x !== predicate; };
  }

  return function(x) { return x === predicate; };
}
