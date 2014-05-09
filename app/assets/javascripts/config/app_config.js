function AppConfig($rootScope, profile, messages) {
  $rootScope.app = { state: 'ready' };

  // Eagerly load profile + messages
  profile.load();
  messages.load();
}

AppConfig.$inject = ['$rootScope', 'profile', 'messages'];
