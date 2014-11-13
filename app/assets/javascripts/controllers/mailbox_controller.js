function MailboxController($scope, $http, $location, messages) {
  this.$scope = $scope;
  this.$http = $http;
  this.$location = $location;
  this.messages = messages;

  $scope.selection = [];
  $scope.currentThread = null;

  this.loadMessages();
}

MailboxController.$inject = ['$scope', '$http', '$location', 'messages'];

MailboxController.prototype.sendRequest = function sendRequest(method) {
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

  return request;
};

MailboxController.prototype.loadMessages = function loadMessages() {
  var $scope = this.$scope;

  this.messages.load().then(function(messages) {
    $scope.threads = messages.threads;

    // TODO: Figure out where to put this Pusher code (probably in its own
    // service?)

    // var realtimeListener = new Pusher(data.subscription_key);
    // var channel = realtimeListener.subscribe($scope.user.email);
    // channel.bind('message', function(message) {
    //   $scope.addMessage(message);
    //   $scope.displayNotice('New message received from ' + message.sender_email + '!');
    //   $scope.$apply();
    // });
  });
};

MailboxController.prototype.deleteMessage = function deleteMessage(message) {
  var $scope = this.$scope,
      messages = this.messages;

  var confirmationPrompt = message.type === 'incoming' ?
    'Are you sure you want to delete this message?' :
    'Really delete your copy of this message (you cannot unsend it)?';

  if (confirm(confirmationPrompt)) {
    this.sendRequest('delete', '/messages/' + message.unique_token, function(response) {
      $scope.displayNotice(response);
      messages.removeMessage(message);
      $scope.showSection('mailbox');
    });
  }
};

MailboxController.prototype.batchSelect = function batchSelect() {
  this.$scope.selection = this.messages.threads.slice(0);
};

MailboxController.prototype.batchDeselect = function batchDeselect() {
  this.$scope.selection = [];
};

MailboxController.prototype.batchRead = function batchRead() {
  var $scope = this.$scope;

  var threadIds = Lazy(this.$scope.selection)
    .map('threadId')
    .toArray();

  this.sendRequest('put', '/batches', { batch: { threads: threadIds } }, function() {
    Lazy($scope.selection).each(function(thread) {
      thread.lastMessage.opened = true;
    });

    $scope.displayNotice('Marked ' + threadIds.length + ' message(s) as read.');
  });
};

MailboxController.prototype.batchDelete = function batchDelete() {
  var ctrl = this,
      $scope = this.$scope,
      messages = this.messages;

  var threadIds = Lazy(this.$scope.selection)
    .map('threadId')
    .toArray();

  this.sendRequest('post', '/batches/delete', { batch: { threads: threadIds } }, function() {
    Lazy($scope.selection).each(function(thread) {
      messages.removeThread(thread);
    });

    $scope.selection = [];
    $scope.displayNotice('Deleted ' + threadIds.length + ' message(s).');

    // After deleting N threads, load older messages to fill up the mailbox.
    ctrl.loadMoreMessages(50 - messages.threads.length);
  });
};

MailboxController.prototype.addMessage = function addMessage(message) {
  this.messages.addMessage(message);
  this.addContact(message.recipient_email);
};

MailboxController.prototype.addContact = function addContact(contact) {
  addToArray(this.$scope.contacts, contact);
};

MailboxController.prototype.toggleSelection = function toggleSelection(thread, event) {
  event.preventDefault();
  event.stopPropagation();

  if (arrayContains(this.$scope.selection, thread)) {
    removeFromArray(this.$scope.selection, thread);
    this.$scope.currentThread = null;
  } else {
    if (event.shiftKey) {
      this.addRange(thread);
    } else {
      this.$scope.selection.push(thread);
    }
    this.$scope.currentThread = thread;
  }
};

MailboxController.prototype.addRange = function addRange(thread) {
  var $scope = this.$scope,
      threads = [thread],
      range;

  if ($scope.currentThread) {
    if ($scope.currentThread.timestamp < thread.timestamp) {
      range = [$scope.currentThread.timestamp, thread.timestamp];
    } else {
      range = [thread.timestamp, $scope.currentThread.timestamp];
    }

    threads = Lazy(this.messages.threads)
      .filter(function(thread) {
        return thread.timestamp >= range[0] && thread.timestamp <= range[1];
      });
  }

  Lazy(threads).each(function(thread) {
    addToArray($scope.selection, thread);
  });
};

MailboxController.prototype.threadIsSelected = function threadIsSelected(thread) {
  return arrayContains(this.$scope.selection, thread);
};

MailboxController.prototype.loadMoreMessages = function(limit) {
  var $scope = this.$scope,
      messages = this.messages;

  if (limit < 1) {
    return;
  }

  messages.loadMore(limit).then(function() {
    $scope.threads = messages.threads;
  });
};

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
