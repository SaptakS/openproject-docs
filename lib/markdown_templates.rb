require 'set'
require 'middleman-core/extension'

# Directory Indexes extension
class MarkdownTemplates < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  self.resource_list_manipulator_priority = 100

  # Update the main sitemap resource list
  # @return Array<Middleman::Sitemap::Resource>
  Contract ResourceList => ResourceList
  def manipulate_resource_list(resources)
    resources.each do |resource|
      # Check if we're running against a README.md
      next unless resource.path.end_with?('.md')

      # Check if template is already .html.md
      next if resource.path.end_with?('.html.md')

      # Force content_type
      resource.options[:content_type] = 'text/html'
      # Force layout
      resource.options[:layout] ||= 'layouts/layout'
    end
  end
end

::Middleman::Extensions.register(:markdown_templates, MarkdownTemplates)
