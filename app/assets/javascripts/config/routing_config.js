function RoutingConfig($routeProvider, $locationProvider) {
  $routeProvider
    .when('/ui/mailbox', {
      template: getSectionHtml('mailbox'),
      controller: 'MailboxController',
      controllerAs: 'ctrl'
    })
    .when('/ui/messages/:messageId', {
      template: getSectionHtml('thread'),
      controller: 'ThreadController',
      controllerAs: 'ctrl'
    })
    .when('/ui/compose', {
      template: getSectionHtml('compose'),
      controller: 'DraftController',
      controllerAs: 'ctrl'
    })
    .when('/ui/profile', {
      template: getSectionHtml('profile'),
      controller: 'ProfileController',
      controllerAs: 'ctrl'
    })
    .otherwise({
      redirectTo: '/ui/mailbox'
    });

  function getSectionHtml(sectionName) {
    return document.getElementById(sectionName).outerHTML;
  }

  $locationProvider.html5Mode(true);
}

RoutingConfig.$inject = ['$routeProvider', '$locationProvider'];
