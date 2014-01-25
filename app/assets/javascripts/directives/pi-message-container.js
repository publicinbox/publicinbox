publicInboxApp.directive('piMessageContainer', function() {

  return {
    require: '?ngModel',
    link: function(scope, element, attrs, ngModel) {
      ngModel.$render = function() {
        var messageWindow   = element[0].contentWindow,
            messageDocument = messageWindow.document;

        // Check out THIS hackiness: we're going to find the closing </html> tag
        // and inject a <script> tag just before it that posts the window's size
        // to the parent window. Genius, right?!
        var html = injectSizeMessage(ngModel.$viewValue);

        // First reset the height of the iframe.
        element.height('auto');

        // Write the HTML to the iframe on the next turn of the event loop so
        // that its document is able to observe the freshly reset document
        // height.
        setTimeout(function() {
          messageDocument.open();
          messageDocument.write(html);
          messageDocument.close();
        }, 0);
      };

      window.addEventListener('message', function(e) {
        element.height(e.data);
      });
    }
  };

  function injectSizeMessage(html) {
    return html +
      '<script>' +
        // 'setTimeout(function() {' +
          'var height = document.body.clientHeight;' +
          'window.parent.postMessage(height, "*");' +
        // '}, 0);' +
      '</script>';
  }

});
