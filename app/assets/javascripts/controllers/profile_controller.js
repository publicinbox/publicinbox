function ProfileController($scope, profile) {
  this.$scope = $scope;
  this.profile = profile;

  this.loadProfile();
}

ProfileController.prototype.loadProfile = function loadProfile() {
  var $scope = this.$scope;

  this.profile.getProfile().then(function(profile) {
    $scope.user = profile;
  });
};

ProfileController.prototype.editProfile = function() {
  this.$scope.editing = true;
};

ProfileController.prototype.cancelEdit = function(e) {
  e.preventDefault();
  this.$scope.editing = false;
};

ProfileController.$inject = ['$scope', 'profile'];
