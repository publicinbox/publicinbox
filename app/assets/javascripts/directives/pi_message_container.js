function PIMessageContainer() {

  return {
    require: '?ngModel',
    link: function(scope, element, attrs, ngModel) {
      ngModel.$render = function() {
        var message = ngModel.$viewValue;
        if (!message) {
          return;
        }

        var html = message.body;
        if (!message.display_in_iframe) {
          element.html(html);
          return;
        }

        var iframe          = getOrInsertIFrame(element),
            messageWindow   = iframe[0].contentWindow,
            messageDocument = messageWindow.document;

        // First reset the height of the iframe.
        iframe.height('auto');

        // Write the HTML to the iframe on the next turn of the event loop so
        // that its document is able to observe the freshly reset document
        // height.
        setTimeout(function() {
          messageDocument.open();
          messageDocument.write(html);

          // Check out THIS hackiness: we're going to tack on an extra <script>
          // tag that adds target="_blank" to all hyperlinks and then posts back
          // the document's size so we can resize the iframe. Genius, right?!
          messageDocument.write(injectCustomScripts());

          messageDocument.close();
        }, 0);
      };

      window.addEventListener('message', function(e) {
        var data = JSON.parse(e.data);

        switch (data.type) {
          case 'mailto':
            scope.compose(data.href.replace(/^\s*mailto:/, ''));
            scope.$apply();
            break;

          case 'height':
            getOrInsertIFrame(element).height(data.height);
            break;
        }
      });
    }
  };

  function getOrInsertIFrame(element) {
    var iframe = element.find('iframe');
    if (iframe.length > 0) {
      return iframe;
    }

    iframe = $('<iframe>');
    element.empty().append(iframe);
    return iframe;
  }

  function injectCustomScripts() {
    var customScripts = '<script>' +
        '(' + updateLinks.toString() + ')();' +
        '(' + reportSize.toString() + ')();' +
      '</script>';

    return customScripts;
  }

  // This function only exists to be toString()'d and injected after the HTML of
  // an e-mail body.
  function updateLinks() {
    var isEmailLink = function(link) {
      return (/^\s*mailto:/).test(link.getAttribute('href'));
    };

    var links = document.querySelectorAll('a[href]');
    for (var i = 0, len = links.length; i < len; ++i) {
      if (isEmailLink(links[i])) {
        continue;
      }

      links[i].setAttribute('target', '_blank');
    }

    document.body.addEventListener('click', function(e) {
      var link = e.target;

      if (link.nodeName !== 'A') {
        return;
      }

      if (isEmailLink(link)) {
        e.preventDefault();

        window.parent.postMessage(JSON.stringify({
          type: 'mailto',
          href: link.getAttribute('href')
        }), '*');
      }
    });
  }

  // This function only exists to be toString()'d and injected after the HTML of
  // an e-mail body.
  function reportSize() {
    var height = document.body.clientHeight;
    window.parent.postMessage(JSON.stringify({
      type: 'height',
      height: height
    }), '*');
  }

}
