var NAV_INLINE_BREAKPOINT = 1100;

var landingHeaderBar = document.getElementById('landing-header-bar');
var headerLinks = document.getElementsByClassName('header-link');

if (landingHeaderBar) {
  window.addEventListener('scroll', function() {
    if (window.scrollY >= 100) {
      landingHeaderBar.classList.add('scrolling-header');
      for (var i = 0; i < headerLinks.length; i++) {
        headerLinks[i].classList.add('scrolling-header-links');
      }
    } else {
      landingHeaderBar.classList.remove('scrolling-header');
      for (var i = 0; i < headerLinks.length; i++) {
        headerLinks[i].classList.remove('scrolling-header-links');
      }
    }
  });
}

var navtoggle = document.getElementById('docs-nav-toggle');
if (navtoggle) {
  navtoggle.addEventListener('click', toggleNavigation);
}

function toggleNavigation() {
  nav = document.getElementsByClassName('header')[0];
  nav.classList.toggle('active');
}

// move document nav to sidebar
(function() {
  var timeofday = document.getElementById('timeofday');
  var tocList = document.querySelector('.js-article-content > ul#markdown-toc');
  var main = document.querySelector('.js-main-wrapper');

  // Set timeofday var depending on the time //

  if (timeofday) {
    var date = new Date();
    var hour = date.getHours();

    if (hour < 11) {
      timeofday.innerHTML = 'morning';
    }

    if (hour >= 11 && hour < 16) {
      timeofday.innerHTML = 'afternoon';
    }

    if (hour >= 16) {
      timeofday.innerHTML = 'evening';
    }
  }

  // if the document has a top level nav
  if (tocList) {
    // append to the sidebar
    var sidebar = document.getElementById('doc-nav');

    if (sidebar) {
      // if there are items
      if (tocList.children.length >= 1) {
        var menu = tocList;
        $(tocList).addClass('nav nav-pills flex-column');
        $(tocList).find('ul').addClass('nav nav-pills flex-column');
        $(tocList).find('a').addClass('nav-link');

        // grab the h1's li anchor text
        var title = document.createElement('h4');
        title.innerHTML = 'On this page:';

        // add the text as a title
        menu.insertBefore(title, menu.children[0]);

        var hasHelpSection = document.getElementById('help-and-feedback');

        // Adds help section anchor to the ToC sidebar
        if(hasHelpSection) {
          var listItem = document.createElement('li');
          var anchor = document.createElement('a');
          var separator = document.createElement('hr');

          anchor.className = 'nav-link';
          anchor.innerHTML = 'Help and feedback';
          anchor.setAttribute('href', '#help-and-feedback');
          listItem.appendChild(anchor);

          menu.insertBefore(separator, menu.children[menu.children.length]);
          menu.insertBefore(listItem, menu.children[menu.children.length]);
        }

        sidebar.appendChild(menu);

        var sidebarContent = sidebar.querySelector('ul');
        var sidebarContentHeight = 0;

        // remove whitespace between elements to prevent list spacing issues
        sidebarContent.innerHTML = sidebarContent.innerHTML.replace(
          new RegExp('>[s\r\n]+<', 'g'),
          '><'
        );

        // When we scroll down to the bottom, we don't want the footer covering
        // the TOC list (sticky behavior)
        document.addEventListener(
          'scroll',
          function() {
            // Wait a cycle for the dimensions to kick in
            if (!sidebarContentHeight) {
              sidebarContentHeight =
                sidebarContent.getBoundingClientRect().height + 55;
            }

            var isTouchingBottom = false;
            if (window.innerWidth >= NAV_INLINE_BREAKPOINT) {
              isTouchingBottom =
                window.scrollY + sidebarContentHeight >= main.offsetHeight;
            }

            if (isTouchingBottom) {
              sidebarContent.style.top =
                main.offsetHeight -
                (window.scrollY + sidebarContentHeight) +
                'px';
            } else {
              sidebarContent.style.top = '';
            }
          },
          { passive: true }
        );
      }
    }

    // main content has-toc
    if (main && main.classList) {
      main.classList.add('has-toc');
    } else {
      main.className += ' has-toc';
    }
  }

  document.addEventListener('DOMContentLoaded', function() {
    var globalNav = document.getElementById('global-nav');
    var media = window.matchMedia('(max-width: 1099px)');

    window.addEventListener('scroll', function(e) {
      var isTouchingBottom = false;

      if (!media.matches) {
        isTouchingBottom =
          window.scrollY + window.innerHeight >=
          document.querySelector('.footer').offsetTop;
      }

      if (isTouchingBottom) {
        globalNav.style.top =
          main.offsetHeight -
          (window.scrollY + globalNav.offsetHeight) +
          80 +
          'px';
      } else {
        globalNav.style.top = '';
      }
    });

    if (media.matches) {
      var el = document.getElementById('markdown-toc');
      el.classList.add('collapse');
      el.classList.add('out');
      el.style.height = '34px';
      el.previousElementSibling.classList.add('collapsed');
    }

    // Adds the ability to auto-scroll to the active item in the TOC
    $(window).on('activate.bs.scrollspy', function() {
      const activeAnchors = document.querySelectorAll('#markdown-toc .nav-link.active');

      if(activeAnchors.length) {
        const sidebarAnchorOffset = 45;
        const lastActiveAnchor = activeAnchors[activeAnchors.length -1];
        const sidebar = document.getElementById('doc-nav');
        // Takes the last active anchor in the tree and scrolls it into view.
        lastActiveAnchor.scrollIntoView();
        sidebar.scrollTop -= sidebarAnchorOffset;
      }
    });
  });
})();
