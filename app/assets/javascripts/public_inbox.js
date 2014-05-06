var PublicInbox = angular.module('PublicInbox', [
  'ngRoute',
  'ngSanitize',
  'ui.codemirror',
  'ui.bootstrap'
]);

PublicInbox.filter('count', CountFilter);

PublicInbox.service('profile', ProfileService);
PublicInbox.service('messages', MessagesService);
PublicInbox.service('draft', DraftService);

PublicInbox.controller('MainController', MainController);
PublicInbox.controller('MailboxController', MailboxController);
PublicInbox.controller('DraftController', DraftController);
PublicInbox.controller('ThreadController', ThreadController);
PublicInbox.controller('ProfileController', ProfileController);

PublicInbox.directive('piEditor', PIEditor);
PublicInbox.directive('piHandleMailtos', PIHandleMailtos);
PublicInbox.directive('piMessageContainer', PIMessageContainer);

PublicInbox.config(RoutingConfig);
