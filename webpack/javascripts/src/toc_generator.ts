import * as tocbot from 'tocbot';


(function () {
  let main = document.querySelector('div.main');
  if (!(main && main.classList.contains('has-toc'))) {
    return;
  }

  let article = document.querySelector('.article-content');
  if (!(article && article.querySelectorAll('h1,h2,h3').length > 2)) {
    return;
  }

  tocbot.init({
    // Where to render the table of contents.
    tocSelector: '#doc-nav',
    // Where to grab the headings to build the table of contents.
    contentSelector: '.article-content',
    // Which headings to grab inside of the contentSelector element.
    headingSelector: 'h1, h2, h3',
    // For headings inside relative or absolute positioned containers within content.
    hasInnerContainers: true,
    // Slower timeout
    throttleTimeout: 150
  });

})();

var NAV_INLINE_BREAKPOINT = 1100;

var navtoggle = document.getElementById('docs-nav-toggle');
if (navtoggle) {
  navtoggle.addEventListener('click', toggleNavigation);
}

function toggleNavigation() {
  let nav = document.getElementsByClassName('header')[0];
  nav.classList.toggle('active');
}

// move document nav to sidebar
(function() {
  let timeofday = document.getElementById('timeofday') as HTMLElement;
  let tocList = document.querySelector('.js-article-content > ul#markdown-toc') as HTMLElement;
  let main = document.querySelector('.js-main-wrapper') as HTMLElement;

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
    let sidebar = document.getElementById('doc-nav');

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

        var sidebarContent = sidebar.querySelector('ul')!;
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
    let globalNav = document.getElementById('global-nav') as HTMLElement;
    let media = window.matchMedia('(max-width: 1099px)');

    if (!globalNav) {
      return;
    }

    window.addEventListener('scroll', function(e) {
      var isTouchingBottom = false;

      if (!media.matches) {
        isTouchingBottom =
          window.scrollY + window.innerHeight >=
          (document.querySelector('.footer') as HTMLElement).offsetTop;
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
      let el = document.querySelector('.toc-list ') as HTMLElement;
      el.classList.add('collapse');
      el.classList.add('out');
      el.style.height = '34px';
      el.previousElementSibling!.classList.add('collapsed');
    }
  });
})();