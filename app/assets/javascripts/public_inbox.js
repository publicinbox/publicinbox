var PublicInbox = angular.module('PublicInbox', [
  'ngSanitize',
  'ui.codemirror',
  'ui.bootstrap'
]);

PublicInbox.filter('count', CountFilter);

PublicInbox.controller('MainController', MainController);
PublicInbox.controller('MessagesController', MessagesController);
PublicInbox.controller('ProfileController', ProfileController);

PublicInbox.directive('piEditor', PIEditor);
PublicInbox.directive('piHandleMailtos', PIHandleMailtos);
PublicInbox.directive('piMessageContainer', PIMessageContainer);
PublicInbox.directive('piNavigableSections', PINavigableSections);
