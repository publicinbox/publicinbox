function MessagesService($q, $http) {
  this.$q = $q;
  this.$http = $http;
}

MessagesService.prototype.getMessages = function getMessages() {
  var svc = this;

  if (!this.messagesRequest) {
    this.messagesRequest = this.$http.get('/messages').then(function(result) {
      var messages = result.data.messages;

      svc.messages = Lazy(messages)
        .indexBy('unique_token')
        .toObject();

      svc.threads = Lazy(messages)
        .groupBy('thread_id')
        .map(function(messages, threadId) {
          return {
            timestamp: Lazy(messages).map('timestamp').min(),
            threadId: threadId,
            messages: Lazy(messages).sortBy('timestamp').toArray(),
            lastMessage: Lazy(messages).last()
          };
        })
        .toArray();

      return messages;
    });
  }

  return this.messagesRequest;
};

MessagesService.prototype.getThreads = function getThreads() {
  var svc = this,
      deferred = this.$q.defer();

  if (this.threads) {
    deferred.resolve(this.threads);

  } else {
    this.getMessage().then(function() {
      deferred.resolve(svc.threads);
    });
  }

  return deferred.promise;
};

MessagesService.prototype.getMessage = function getMessage(messageId) {
  var svc = this,
      deferred = this.$q.defer();

  if (this.messages) {
    deferred.resolve(this.messages[messageId]);

  } else {
    this.getMessages().then(function() {
      deferred.resolve(svc.messages[messageId]);
    });
  }

  return deferred.promise;
};

MessagesService.prototype.getThread = function getThread(threadId) {
  var svc = this,
      deferred = this.$q.defer();

  if (this.threads) {
    deferred.resolve(this.findThread(this.threads, threadId));

  } else {
    this.getMessages().then(function() {
      deferred.resolve(svc.findThread(svc.threads, threadId));
    });
  }

  return deferred.promise;
};

MessagesService.prototype.findThread = function findThread(threads, threadId) {
  return Lazy(threads).findWhere({ threadId: threadId });
};

MessagesService.prototype.sendMessage = function sendMessage(message) {
  var request = this.$http.post('/messages', { message: message });

  return request.then(function(response) {
    return response.data;
  });
};

MessagesService.$inject = ['$q', '$http'];
