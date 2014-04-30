function MainController($scope, $timeout) {

  $scope.showSection = function showSection(sectionName, title) {
    if (sectionName.charAt(0) === '#') {
      sectionName = sectionName.substring(1);
    }

    $scope.title = title || $scope.sections[sectionName].title;
    $scope.activeSection = sectionName;
  };

  $scope.isActiveSection = function isActiveSection(sectionName) {
    return $scope.activeSection === sectionName;
  };

  $scope.revealNav = function revealNav() {
    // Yes, this is unfortunate. I'm sure there's a less hacky way to accomplish
    // the same thing. Alas, this feels acceptable to my tired brain at the
    // moment.
    $scope.revealingNav = true;

    $scope.nav.state = 'revealed';
  };

  $scope.hideNav = function hideNav() {
    if ($scope.revealingNav) {
      $scope.revealingNav = false;
      return;
    }

    $scope.nav.state = 'ready';
  };

  $scope.activeSection = 'inbox';

  $scope.displayNotice = function displayNotice(message, style) {
    $scope.notice.message = message;
    $scope.notice.style = style || 'info';
    $scope.notice.state = 'displayed';
    $scope.hideNoticeAfter(3000);
  };

  $scope.hideNotice = function hideNotice() {
    $scope.notice.state = 'hiding';
  };

  $scope.hideNoticeAfter = function hideNoticeAfter(delay) {
    $timeout(function() {
      $scope.hideNotice();
      $timeout(function() {
        $scope.notice.message = null;
        $scope.notice.state = 'hidden';
      }, 1000);
    }, delay);
  };

  $scope.hideNoticeAfter(3000);

  $scope.nav = { state: 'ready' };
  $scope.app = { state: 'ready' };

}

MainController.$inject = ['$scope', '$timeout'];
