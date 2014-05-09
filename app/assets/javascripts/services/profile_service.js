function ProfileService($http) {
  this.$http = $http;
}

ProfileService.$inject = ['$http'];

ProfileService.prototype.load = function() {
  var svc = this;

  if (!this.promise) {
    this.promise = this.$http.get('/profile').then(function(result) {
      return result.data;
    });
  }

  return this.promise;
};
