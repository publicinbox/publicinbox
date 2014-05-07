function Thread(data) {
  this.threadId = data.threadId;
  this.messages = data.messages || [];
}

Object.defineProperty(Thread.prototype, 'lastMessage', {
  get: function() {
    return this.messages[this.messages.length - 1];
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
