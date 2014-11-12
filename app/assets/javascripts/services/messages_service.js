function MessagesService($http) {
  this.$http = $http;
}

MessagesService.$inject = ['$http'];

MessagesService.prototype.load = function load() {
  var svc = this;

  if (!this.promise) {
    this.promise = this.$http.get('/messages').then(function(result) {
      var response = result.data;

      svc.messages = response.messages;
      svc.contacts = response.contacts;

      svc.messageMap = Lazy(svc.messages)
        .indexBy('unique_token')
        .toObject();

      svc.threads = Lazy(svc.messages)
        .groupBy('thread_id')
        .map(function(messages, threadId) {
          return new Thread({
            threadId: threadId,
            messages: messages
          });
        })
        .toArray();

      svc.threadMap = Lazy(svc.threads)
        .indexBy('threadId')
        .toObject();

      return svc;
    });
  }

  return this.promise;
};

MessagesService.prototype.getThreads = function getThreads() {
  return this.load().then(function(svc) {
    return svc.threads;
  });
};

MessagesService.prototype.getMessage = function getMessage(messageId) {
  return this.load().then(function(svc) {
    return svc.messageMap[messageId];
  });
};

MessagesService.prototype.getThread = function getThread(threadId) {
  return this.load().then(function(svc) {
    return svc.threadMap[threadId];
  });
};

MessagesService.prototype.sendMessage = function sendMessage(message) {
  var request = this.$http.post('/messages', { message: message });

  return request.then(function(response) {
    return response.data;
  });
};

MessagesService.prototype.addMessage = function addMessage(message) {
  this.messages.push(message);
  this.messageMap[message.unique_token] = message;

  var thread = this.threadMap[message.thread_id];
  if (!thread) {
    thread = new Thread({ threadId: message.thread_id });
    this.threads.push(thread);
    this.threadMap[message.thread_id] = thread;
  }

  thread.messages.push(message);
};

MessagesService.prototype.removeMessage = function removeMessage(message) {
  // TODO: Move this method into an appropriate place.
  removeFromArray(this.messages, message);
  delete this.messageMap[message.unique_token];

  var thread = this.threadMap[message.thread_id];
  if (thread) {
    removeFromArray(thread.messages, message);
    if (thread.isEmpty()) {
      removeFromArray(this.threads, thread);
      delete this.threadMap[message.thread_id];
    }
  }
};

MessagesService.prototype.removeThread = function removeThread(thread) {
  var self = this;

  // #removeMessage removes a message from its thread; thus we need to first
  // make a copy of messages we want to remove (or else we'll be modifying the
  // array while we're iterating over it).
  var messages = thread.messages.slice(0);

  Lazy(messages).each(function(message) {
    self.removeMessage(message);
  });
};
