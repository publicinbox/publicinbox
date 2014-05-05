function ThreadController($scope, $routeParams, $http, messages) {
  this.$scope = $scope;
  this.$http = $http;
  this.messages = messages;

  var ctrl = this;
  this.messages.getThread($routeParams.messageId).then(function(thread) {
    ctrl.showThread(thread);
  });
}

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

ThreadController.$inject = ['$scope', '$routeParams', '$http', 'messages'];
