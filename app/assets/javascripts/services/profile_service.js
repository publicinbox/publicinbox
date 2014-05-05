function ProfileService($http) {
  this.$http = $http;
}

ProfileService.$inject = ['$http'];

ProfileService.prototype.getProfile = function() {
  var svc = this;

  if (!this.profileRequest) {
    this.profileRequest = this.$http.get('/profile').then(function(result) {
      return  result.data;
    });
  }

  return this.profileRequest;
};
