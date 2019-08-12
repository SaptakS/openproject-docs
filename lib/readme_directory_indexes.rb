require 'set'
require 'middleman-core/extension'

# Directory Indexes extension
class ReadmeDirectoryIndexes < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  # self.resource_list_manipulator_priority = 100

  # Update the main sitemap resource list
  # @return Array<Middleman::Sitemap::Resource>
  Contract ResourceList => ResourceList
  def manipulate_resource_list(resources)
    resources.each do |resource|
      # Check if we're running against a README.md
      next unless resource.destination_path.include?('README')

      parts = resource.destination_path.split('/')

      # Drop readme part
      parts = parts[0..-2]

      # Re-add index file path
      parts << 'index.html'
      resource.destination_path = parts.join('/')

      puts "Rewriting #{resource.path} to #{resource.destination_path}"
      # Force content_type
      resource.options[:content_type] = 'text/html'
      # Force layout
      resource.options[:layout] ||= 'layouts/layout'
    end
  end
end

::Middleman::Extensions.register(:readme_directory_indexes, ReadmeDirectoryIndexes)
