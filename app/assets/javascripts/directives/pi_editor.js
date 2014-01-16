publicInboxApp.directive('piEditor', function() {

  return {
    link: function(scope, element) {
      CodeMirror.fromTextArea(element[0], {
        mode: 'markdown'
      });
    }
  };

});
