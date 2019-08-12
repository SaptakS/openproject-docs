/*
 * Gives us the ability to toggle a class for a specific selector.
 *
 * Usage: Simply add the `data-gl-class-toggle` and `data-target` attributes to the desired element
 *
 * The following example will toggle the '.active' class on the element with id '#global-nav'
 *  <button type="button" data-gl-class-toggle="active" data-target="#global-nav">My Toggle</button>
 */
(function () {
  const toggles = document.querySelectorAll('[data-gl-class-toggle]');

  if(toggles.length) {
    for (let i = 0; i < toggles.length; i++) {
      addListener(toggles[i]);
    }
  }

  function addListener(toggle) {
    toggle.addEventListener('click', toggleClicked)
  }

  function toggleClicked(e) {
    const toggle = e.target;
    const targetSelector = toggle.dataset.target;
    const classToToggle = toggle.dataset.glClassToggle;
    const target = document.querySelector(targetSelector);

    if(!target) {
      console.warn('No target found for selector > ', targetSelector);
      return;
    }

    target.classList.toggle(classToToggle);
  }
})();
