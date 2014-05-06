function MessagesService($http) {
  this.$http = $http;
}

MessagesService.$inject = ['$http'];

MessagesService.prototype.getMessages = function getMessages() {
  var svc = this;

  if (!this.messagesRequest) {
    this.messagesRequest = this.$http.get('/messages').then(function(result) {
      svc.messages = result.data.messages;

      svc.messageMap = Lazy(svc.messages)
        .indexBy('unique_token')
        .toObject();

      svc.threads = Lazy(svc.messages)
        .groupBy('thread_id')
        .map(function(messages, threadId) {
          var thread = {
            threadId: threadId,
            messages: Lazy(messages).sortBy('timestamp').toArray(),
            lastMessage: Lazy(messages).last()
          };

          thread.timestamp = thread.lastMessage.timestamp;

          return thread;
        })
        .toArray();

      svc.threadMap = Lazy(svc.threads)
        .indexBy('threadId')
        .toObject();

      return svc.messages;
    });
  }

  return this.messagesRequest;
};

MessagesService.prototype.getThreads = function getThreads() {
  var svc = this;
  return this.getMessages().then(function() {
    return svc.threads;
  });
};

MessagesService.prototype.getMessage = function getMessage(messageId) {
  var svc = this;
  return this.getMessages().then(function() {
    return svc.messageMap[messageId];
  });
};

MessagesService.prototype.getThread = function getThread(threadId) {
  var svc = this;
  return this.getMessages().then(function() {
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
    thread = this.threadMap[message.thread_id] = {
      timestamp: message.timestamp,
      threadId: threadId,
      messages: []
    };
  }

  thread.messages.push(message);
  thread.lastMessage = message;
};
