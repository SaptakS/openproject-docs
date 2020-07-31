# openproject-docs

Static generator for OpenProject documentation

## How to use locally

**Preparation**

1. Clone this repository
2. Run `bundle install`
3. Run `npm install`

**Starting middleman for development**

Just run `bundle exec middleman`. This will run both middleman ruby server and webpack with watchers
and live reloading and start the development server at `http://localhost:4567` by default.

## How to develop

The site source is located at `source/` with localizable templates living under `source/localizable/`. They are being built into the URLs `/:language/<whatever is under localizable>`
for all languages that are activated in the configuration.

### Updating the core documentation

We are pulling the documentation from the openproject core at `https://github.com/opf/openproject/tree/documentation/help` so that Birthe can
work in peace on her changes for now.

To update the core docs use `OPENPROJECT_CORE=/path/to/openproject ./scripts/pull_repos.rb`.

This will place all relevant guides under `help/` into the `source/localizable/openproject/*` folders and replace some README.md files into `README.index.html`
so that middleman will use them as index files.

### Working on CSS / JS

Javascript and Stylesheets are being run by webpack and put into a dist bundle. Work in the source files at `webpack/javascripts` and `webpack/stylesheets`.

### Updating product data / nav

Middleman comes with a YAML setup for static data that you can extend freely in the `data/` directory. We currently use it to set up
the grid of "products" (gitlab term) or rather documentation topics.

Also the left hand navigation is built from there which we will still need to update, or generate automatically.

## Deploying the site

Always commit and push your changes first to the `master` branch. Then run

```
bundle exec rake deploy
```

which will run the middleman static site generator to output all changes into `build/` , which then gets copied and pushed in the `gh-pages`
branch. This in turn builds and updates the https://finnlabs.github.io/openproject-docs site after a few minutes automatically.

This build step happens daily in the `middleman-docs` branch of travis-ci-jobs: https://travis-ci.com/finnlabs/travis-ci-jobs/branches
