function ThreadController($scope, $location, $routeParams, $http, messages, draft) {
  this.$scope = $scope;
  this.$location = $location;
  this.$routeParams = $routeParams;
  this.$http = $http;
  this.messages = messages;
  this.draft = draft;

  var ctrl = this;
  this.messages.getThread($routeParams.messageId).then(function(thread) {
    ctrl.showThread(thread);
  });
}

ThreadController.$inject = ['$scope', '$location', '$routeParams', '$http', 'messages', 'draft'];

ThreadController.prototype.showThread = function showThread(thread) {
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
};

ThreadController.prototype.compose = function compose(recipient_email) {
  this.draft.compose(recipient_email);
};

ThreadController.prototype.replyToMessage = function replyToMessage(message) {
  this.draft.replyTo(message);
};

ThreadController.prototype.deleteMessage = function deleteMessage(message) {
  var $scope = this.$scope,
      $location = this.$location,
      messages = this.messages;

  this.$http['delete']('/messages/' + message.unique_token)
    .success(function() {
      messages.removeMessage(message);
      if ($scope.thread.isEmpty()) {
        $location.path('/ui/mailbox');
      }
      $scope.displayNotice('Successfully deleted message.');
    })
    .error(function() {
      $scope.displayNotice('Failed to delete message for some reason...');
    });
};
