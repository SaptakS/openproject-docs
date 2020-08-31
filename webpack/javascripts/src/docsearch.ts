import * as docsearch from '../vendor/docsearch.min';

docsearch({
  apiKey: 'd512e10709e766090965031ff2f59675',
  indexName: 'openproject',
  inputSelector: '.docsearch',
  algoliaOptions: {
    // Number of results shown in the search dropdown
    'hitsPerPage': 10
  },
  debug: false, // Set debug to true if you want to inspect the dropdown
  autocompleteOptions: {
    'autoselect': false
  }
});