/*
 * Hides mobile header on scroll down and shows it on scroll up
 * by moving it in and out of the screen
 */
(function () {
  const headerHeight = '55px';
  let prevScrollPos = window.pageYOffset;

  window.addEventListener('scroll', function() {
    // Only on mobile screen sizes and when sidebar is closed and search not opened
    if (window.innerWidth >= 680 ||
        $('.nav-wrapper').hasClass('active') ||
        $('.header--element-container').hasClass('active')) {
      return;
    }

    let currentScrollPos = window.pageYOffset;
    if (prevScrollPos >= currentScrollPos) {
      $('.header, #landing-header-bar').css({ top: '0px'});
    } else {
      $('.header, #landing-header-bar').css({ top: '-' + headerHeight });
    }
    prevScrollPos = currentScrollPos;
  });
})();
