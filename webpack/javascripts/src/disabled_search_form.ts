/*
 * Gives us the ability to toggle a class for a specific selector.
 *
 * Usage: Simply add the `data-gl-class-toggle` and `data-target` attributes to the desired element
 *
 * The following example will toggle the '.active' class on the element with id '#global-nav'
 *  <button type="button" data-gl-class-toggle="active" data-target="#global-nav">My Toggle</button>
 */
(function () {
  const form = document.getElementById('search-form') as HTMLFormElement|null;

  if (form) {
    form.onsubmit = () => false;
  }
})();
