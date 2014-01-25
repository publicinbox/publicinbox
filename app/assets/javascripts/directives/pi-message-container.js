publicInboxApp.directive('piMessageContainer', function() {

  return {
    require: '?ngModel',
    link: function(scope, element, attrs, ngModel) {
      ngModel.$render = function() {
        var messageWindow   = element[0].contentWindow,
            messageDocument = messageWindow.document;

        // Check out THIS hackiness: we're going to tack on an extra <script>
        // tag that adds target="_blank" to all hyperlinks and then posts back
        // the document's size so we can resize the iframe. Genius, right?!
        var html = injectCustomScripts(ngModel.$viewValue);

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

  function injectCustomScripts(html) {
    return html +
      '<script>' +
        '(' + updateLinks.toString() + ')();' +
        '(' + reportSize.toString() + ')();' +
      '</script>';
  }

  // This function only exists to be toString()'d and injected after the HTML of
  // an e-mail body.
  function updateLinks() {
    var links = document.querySelectorAll('a[href]');
    for (var i = 0, len = links.length; i < len; ++i) {
      // Skip mailto: links
      if (links[i].getAttribute('href').match(/^\s*mailto:/)) {
        continue;
      }

      links[i].setAttribute('target', '_blank');
    }
  }

  // This function only exists to be toString()'d and injected after the HTML of
  // an e-mail body.
  function reportSize() {
    var height = document.body.clientHeight;
    window.parent.postMessage(height, '*');
  }

});
