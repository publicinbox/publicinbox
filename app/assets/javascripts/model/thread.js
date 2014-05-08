function Thread(data) {
  this.threadId = data.threadId;
  this.messages = data.messages || [];
}

Object.defineProperty(Thread.prototype, 'lastMessage', {
  get: function() {
    return this.messages[this.messages.length - 1];
  }
});

Object.defineProperty(Thread.prototype, 'heading', {
  get: function() {
    return this.messages[0].subject;
  }
});

Object.defineProperty(Thread.prototype, 'permalink', {
  get: function() {
    return this.messages[0].permalink;
  }
});

Object.defineProperty(Thread.prototype, 'timestamp', {
  get: function() {
    return this.lastMessage.timestamp;
  }
});

Object.defineProperty(Thread.prototype, 'opened', {
  get: function() {
    return this.lastMessage.opened;
  }
});

Thread.prototype.isEmpty = function isEmpty() {
  return this.messages.length === 0;
};
