function ProfileController($scope) {
  this.$scope = $scope;
}

ProfileController.prototype.editProfile = function() {
  this.$scope.editing = true;
};

ProfileController.prototype.cancelEdit = function(e) {
  e.preventDefault();
  this.$scope.editing = false;
};
