function AppConfig($rootScope) {
  $rootScope.app = { state: 'ready' };
}

AppConfig.$inject = ['$rootScope'];
