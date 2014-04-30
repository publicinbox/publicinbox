// In general, don't use this directive; use the ui-codemirror directive
// instead. This one is just for the simple case where you have a form that
// does a post and a page reload, and you want CodeMirror to replace a textarea
// in the form. The ui-codemirror directive is more heavyweight but it handles
// Angular bindings properly (this one doesn't).
function PIEditor() {

  function tryParse(string, callback) {
    try {
      if (typeof string !== 'string') {
        return;
      }

      callback(JSON.parse(string));

    } catch (e) {
      // Do nothing.
    }
  }

  return {
    link: function(scope, element, attributes) {
      var options = {
        mode: 'markdown'
      };

      tryParse(attributes.piEditor, function(data) {
        angular.extend(options, data);
      });

      CodeMirror.fromTextArea(element[0], options);
    }
  };

}
