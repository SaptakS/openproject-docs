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

The documentation text itself is not maintained in this repository but is pulled from OpenProject, where  `https://github.com/opf/openproject/tree/dev/docs` is the upstream location.

Locally, when developing, use `OPENPROJECT_CORE=/path/to/openproject rake build`
with the `OPENPROJECT_CORE` being the *absolute* path pointing to the checkout of the core with the branch set to to the current release branch (or whatever branch you make changes on)

This will place all relevant guides under `docs/` into the `source/localizable/openproject/*` folders will put all api documenation, after having rendered them to html using aglio, to `source/api`. Some README.md files will be transformed into `README.index.html`
so that middleman will use them as index files.

### Working on CSS / JS

Javascript and Stylesheets are being run by webpack and put into a dist bundle. Work in the source files at `webpack/javascripts` and `webpack/stylesheets`.

### Updating product data / nav

Middleman comes with a YAML setup for static data that you can extend freely in the `data/` directory. We currently use it to set up
the grid of "products" (gitlab term) or rather documentation topics.

Also the left hand navigation is built from there which we will still need to update, or generate automatically.

## Deploying the site

Update the repository and push all the changes to the `master` branch. The CI will then dockerize the repository using the `https://ci.openproject.com/view/Dockerize/job/openproject-docs-dockerize/` job which will lead to the configured branches being deployed to `https://docs.openproject.org/` (the current release) and `https://docs.openproject-edge.com/` (the dev branch)

If a new branch is to be depoyed to `docs` the configuration for the job needs to be altered:
`https://ci.openproject.com/view/Dockerize/job/openproject-docs-dockerize/configure`
