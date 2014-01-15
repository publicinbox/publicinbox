$(document).ready(function() {
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
