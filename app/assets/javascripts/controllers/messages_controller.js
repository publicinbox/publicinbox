function MessagesController($scope, $http) {
  this.$scope = $scope;
  this.$http = $http;

  $scope.draft = {};
  $scope.selection = [];

  var ctrl = this;
  $scope.$on('mailto', function(e, email) {
    ctrl.compose(email);
  });

  this.loadMessages();
}

MessagesController.$inject = ['$scope', '$http'];

MessagesController.prototype.sendRequest = function sendRequest(method) {
  var $scope = this.$scope,
      requestArgs = Array.prototype.slice.call(arguments, 1),
      callback = requestArgs.pop(),
      request = this.$http[method].apply(this.$http, requestArgs)

  request.success(callback);

  request.error(function(response) {
    $scope.displayNotice(response, 'error');
  });

  request['finally'](function() {
    $scope.app.state = 'ready';
  });

  $scope.app.state = 'loading';

  return request;
};

MessagesController.prototype.loadMessages = function loadMessages() {
  var $scope = this.$scope;

  return this.sendRequest('get', '/messages', function(data) {
    $scope.user     = data.user;
    $scope.contacts = data.contacts;

    $scope.threads = Lazy(data.messages)
      .groupBy('thread_id')
      .map(function(messages, threadId) {
        return {
          timestamp: Lazy(messages).map('timestamp').min(),
          thread_id: threadId,
          messages: Lazy(messages).sortBy('timestamp').toArray(),
          lastMessage: Lazy(messages).last()
        };
      })
      .toArray();

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

MessagesController.prototype.showThread = function showThread(thread, e) {
  e.preventDefault();

  var $scope      = this.$scope,
      lastMessage = thread.lastMessage;

  if (!lastMessage.opened) {
    this.$http.put('/messages/' + lastMessage.unique_token)
      .success(function() {
        lastMessage.opened = true;
      })
      .error(function() {
        $scope.displayNotice('Failed to mark message as "opened" for some reason...');
      });
  }

  $scope.thread = thread;
  $scope.message = lastMessage;

  $scope.showSection('thread', lastMessage.subject || '[No subject]');
};

MessagesController.prototype.compose = function compose(recipient_email) {
  this.$scope.draft = {
    recipient_email: recipient_email
  };

  this.$scope.showSection('compose');
};

MessagesController.prototype.replyToMessage = function replyToMessage(message) {
  this.$scope.draft = {
    external_source_id: message.external_id,
    recipient_email: message.display_email,
    subject: prepend('Re: ', message.subject)
  };

  this.$scope.showSection('compose');
};

MessagesController.prototype.addCc = function addCc() {
  this.$scope.draft.include_cc = true;
};

MessagesController.prototype.sendMessage = function sendMessage(message) {
  if (!message.body) {
    if (!confirm('Really send a message without a body?')) {
      return;
    }

  } else if (!message.subject) {
    if (!confirm('Really send a message without a subject?')) {
      return;
    }
  }

  var $scope = this.$scope;

  $scope.app.state = 'loading';

  var request = this.$http.post('/messages', { message: message })
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

MessagesController.prototype.deleteMessage = function deleteMessage(message) {
  var $scope = tihs.$scope;

  var confirmationPrompt = message.type === 'incoming' ?
    'Are you sure you want to delete this message?' :
    'Really delete your copy of this message (you cannot unsend it)?';

  if (confirm(confirmationPrompt)) {
    this.sendRequest('delete', '/messages/' + message.unique_token, function(response) {
      $scope.displayNotice(response);
      $scope.removeMessage(message);
      $scope.showSection('mailbox');
    });
  }
};

MessagesController.prototype.batchRead = function batchRead() {
  var $scope = this.$scope;

  var tokens = this.$scope.selection.map(function(message) {
    return message.unique_token;
  });

  this.sendRequest('put', '/batches', { batch: { messages: tokens } }, function() {
    angular.forEach($scope.selection, function(message) {
      message.opened = true;
    });

    $scope.displayNotice('Marked ' + tokens.length + ' messages as read.');
  });
};

MessagesController.prototype.batchDelete = function batchDelete() {
  var $scope = this.$scope;

  var tokens = $scope.selection.map(function(message) {
    return message.unique_token;
  });

  this.sendRequest('delete', '/batches?messages=' + tokens.join(','), function() {
    angular.forEach($scope.selection, function(message) {
      $scope.removeMessage(message);
    });
    $scope.selection = [];

    $scope.displayNotice('Successfully deleted ' + tokens.length + ' messages.');
  });
};

MessagesController.prototype.addMessage = function addMessage(message) {
  this.$scope.messages.push(message);
  this.$scope.addContact(message.recipient_email);
};

MessagesController.prototype.removeMessage = function removeMessage(message) {
  removeFromArray(this.$scope.messages, message);
};

MessagesController.prototype.addContact = function addContact(contact) {
  addToArray(this.$scope.contacts, contact);
};

MessagesController.prototype.toggleSelection = function toggleSelection(message) {
  if (arrayContains(this.$scope.selection, message)) {
    removeFromArray(this.$scope.selection, message);
  } else {
    this.$scope.selection.push(message);
  }
};

MessagesController.prototype.messageIsSelected = function messageIsSelected(message) {
  return arrayContains(this.$scope.selection, message);
};

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
