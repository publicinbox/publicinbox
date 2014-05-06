function PIHandleMailtos(draft) {

  return {
    link: function(scope, element) {
      element.on('click', 'a[href^="mailto:"]', function(e) {
        e.preventDefault();

        var email = $(this).attr('href').substring(7);
        draft.compose(email);
      });
    }
  };

}

PIHandleMailtos.$inject = ['draft'];
