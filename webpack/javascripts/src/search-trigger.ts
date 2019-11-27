(function () {
  jQuery('.trigger-search-button')
    .on('click', () => {
      setTimeout(() => {
        jQuery('.docsearch.ds-input').trigger('focus');
      }, 20);
      return false;
    });

})();
