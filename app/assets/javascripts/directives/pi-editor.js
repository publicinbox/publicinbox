// In general, don't use this directive; use the ui-codemirror directive
// instead. This one is just for the simple case where you have a form that
// does a post and a page reload, and you want CodeMirror to replace a textarea
// in the form. The ui-codemirror directive is more heavyweight but it handles
// Angular bindings properly (this one doesn't).
publicInboxApp.directive('piEditor', function() {

  return {
    link: function(scope, element) {
      CodeMirror.fromTextArea(element[0], {
        mode: 'markdown'
      });
    }
  };

});
