// It seems the only way to check for the existence of a module
// is to catch an exception when trying to load it?
// http://stackoverflow.com/questions/19206553
function moduleExists(moduleName) {
  try {
    angular.module(moduleName);
    return true;
  } catch (e) {
    return false;
  }
}

// The idea here is to just load the modules that are currently defined, mainly
// to handle the issue of not having a separate version of everything for users
// vs. guests.
function getModules() {
  var modules = [];

  angular.forEach(['ngSanitize', 'ui.codemirror', 'ui.bootstrap'], function(moduleName) {
    if (moduleExists(moduleName)) {
      modules.push(moduleName);
    }
  });

  return modules;
}

var PublicInbox = angular.module('PublicInbox', getModules());

PublicInbox.controller('MainController', MainController);
PublicInbox.controller('MessagesController', MessagesController);
PublicInbox.controller('TestMessageController', TestMessageController);

PublicInbox.directive('piEditor', PIEditor);
PublicInbox.directive('piHandleMailtos', PIHandleMailtos);
PublicInbox.directive('piMessageContainer', PIMessageContainer);
PublicInbox.directive('piNavigableSections', PINavigableSections);
