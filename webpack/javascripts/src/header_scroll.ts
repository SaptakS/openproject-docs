import * as $ from "jquery";

/*
 * Hides mobile header on scroll down and shows it on scroll up
 * by sliding it in and out of the screen
 */
(function () {
  const headerHeight = 55;
  let prevScrollPos = window.pageYOffset;

  if (window.innerWidth <= 680) {
    window.addEventListener('scroll', mobileScrollHandler);
  }

  function mobileScrollHandler() {
    // Condition needed for safari browser to avoid negative positions
    let currentScrollPos = window.pageYOffset! < 0 ? 0 : window.pageYOffset!;
    // Only on mobile and if sidebar is not opened or search bar is opened
    if ($('.nav-wrapper').hasClass('active') ||
        $('.header--element-container').hasClass('active') ||
        Math.abs(currentScrollPos - prevScrollPos) <= headerHeight) { // to avoid flickering at the end of the page
      return;
    }

    let headerHidden:boolean = true;
    if (prevScrollPos !== undefined && currentScrollPos !== undefined && (prevScrollPos > currentScrollPos)) {
      headerHidden = false;
    }
    toggleTopMenu(headerHidden);
    prevScrollPos = currentScrollPos;
  }

  // Slide top menu in or out of viewport
  function toggleTopMenu(headerHidden:boolean) {
    $('body').toggleClass('-header-scrolled', headerHidden);
  }
})();
