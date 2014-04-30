function PIHandleMailtos() {

  return {
    link: function(scope, element) {
      element.on('click', 'a[href^="mailto:"]', function(e) {
        e.preventDefault();

        var email = $(this).attr('href').substring(7);
        scope.compose(email);
      });
    }
  };

}
