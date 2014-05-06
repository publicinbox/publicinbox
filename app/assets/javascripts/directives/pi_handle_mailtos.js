function PIHandleMailtos($location) {

  return {
    link: function(scope, element) {
      element.on('click', 'a[href^="mailto:"]', function(e) {
        e.preventDefault();

        var email = $(this).attr('href').substring(7);
        $location.url('/ui/compose?to=' + encodeURIComponent(email));
      });
    }
  };

}

PIHandleMailtos.$inject = ['$location'];
