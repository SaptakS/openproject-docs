import * as $ from "jquery";

(function () {
  $('.trigger-search-button')
    .on('click', () => {
      setTimeout(() => {
        $('.docsearch.ds-input').trigger('focus');
      }, 20);
      return false;
    });

})();
