$(document).ready(function() {
  var navLinks = $('body > nav ul li a'),
      sections = $('body > main section');

  navLinks.on('click', function(e) {
    var target  = $(this).attr('href');

    if (target.charAt(0) !== '#') {
      return;
    }

    e.preventDefault();
    sections.hide();
    $(target).show();
  });

  function afterDelay(delay, callback) {
    return setTimeout(callback, delay);
  }

  function onNextTransition(element, callback) {
    var possibleEvents = [
      'webkitTransitionEnd',
      'otransitionend',
      'oTransitionEnd',
      'msTransitionEnd',
      'transitionend'
    ];

    element.one(possibleEvents.join(' '), callback);
  }

  sections.first().show();

  // Slide away any alert(s) after 3 seconds
  afterDelay(3000, function() {
    var notice = $('#notice');
    if (!notice.length) { return; }

    notice.addClass('exiting');
    onNextTransition(notice, function() {
      notice.remove();
    });
  });
});
