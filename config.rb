require 'active_support/all'
require_relative './lib/readme_directory_indexes'
require_relative './lib/markdown_templates'
require_relative './lib/trailing_slashes'

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

# Layouts
# https://middlemanapp.com/basics/layouts/


# Docs specific settings
set :breadcrumbs, true
set :site_url, "http://localhost:4567"

use ::Rack::TrailingSlashes

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'
activate :i18n, mount_at_root: :en, langs: [:en]

configure :development do
  activate :livereload
end


# Activate /openproject to map to /openproject/README.* or /openproject/index.*
activate :directory_indexes
activate :readme_directory_indexes

# Middleman wants all templated files to have the target extension contained,
# such as `foo.html.erb` or `foo.html.md`. Since we import from core, there are only
# files such as `README.md` so we need to force them to become templates
activate :markdown_templates

set :markdown_engine, :kramdown
set :markdown, fenced_code_blocks: true,
               input: "GFM",
               parse_block_html: true,
               smartypants: true,
               default_lang: 'Plain Text',
               hard_wrap: false,
               auto_ids: true

activate :syntax, line_numbers: false

activate :external_pipeline,
         name: :webpack,
         command: build? ?
           "./node_modules/webpack/bin/webpack.js --bail -p" :
           "./node_modules/webpack/bin/webpack.js --watch -d --progress --color",
         source: ".tmp/dist",
         latency: 1

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  set :site_url, ENV.fetch("SITE_URL") { "https://docs.openproject.org" }
  activate :asset_hash
end
