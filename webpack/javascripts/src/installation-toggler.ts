/*
 * Create installation sections dynamically in the packaged installation guide
 */
(function () {
  const toggles = document.querySelectorAll('div.installation-distribution');

  if(!toggles.length) {
    return;
  }

  const ul = document.createElement('ul');
  const contents = document.createElement('div');
  ul.classList.add('nav', 'nav-pills');
  contents.classList.add('tab-content');

  toggles.forEach((item:HTMLDivElement, i:number) => {
    item.style.display = 'none';

    const li = document.createElement('li');
    li.classList.add('nav-item');
    const link = document.createElement('a');
    link.classList.add('nav-item', 'nav-link');
    link.id = `install-tab-${i}`;
    link.dataset.toggle = 'pill';
    link.href = `#install-content-${i}`;
    link.setAttribute('role', 'tab');
    link.setAttribute('aria-controls', `install-content-${i}`);
    link.textContent = item.querySelector('h3')!.textContent;

    const content = document.createElement('div');
    content.classList.add('tab-pane', 'fade');
    content.id = `install-content-${i}`;
    content.setAttribute('role', 'tabpanel');
    content.setAttribute('aria-labelledby', `install-tab-${i}`);

    item.children[0].remove();
    content.append(...Array.from(item.children));

    if (i === 0) {
      link.classList.add('active');
      content.classList.add('show', 'active');
    }

    li.appendChild(link);
    ul.appendChild(li);
    contents.appendChild(content);
  });
  const nav = document.createElement('nav');
  nav.appendChild(ul);
  const parent = toggles[0].parentElement!;
  parent.insertBefore(nav, toggles[0]);
  parent.insertBefore(contents, toggles[0]);
})();
