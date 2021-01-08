module NavHelper

  def product_links(path, with_index: false)
    pages_for_product(path, with_index: with_index)
      .map do |resource|

        # Skip this item if requested by its frontmatter
        next if resource.data.sidebar_navigation == false

        path = '/' + resource.path.gsub(/\.html$/, '').delete_prefix('/')
        title = resource.metadata[:page][:title] || resource.data.title || derive_title(resource)

        {
          resource: resource,
          is_index: path.end_with?('index'),
          title: resource.data.sidebar_navigation&.title || title,
          priority: (resource.data.sidebar_navigation&.priority || 1).to_i,
          data: resource.data,
          path: path,
          url: path.chomp('/index')
        }
      end
      .compact
  end

  ##
  # Generates the sidebar menu for the given section_prefix
  # e.g., "user-guide" will find all pages behind source/user-guide/,
  # group them by subfolders (if any) and sorts the nav items
  def generate_section_navigation(section, args = {})
    section_name = section.delete_prefix('/').chomp('/').split('/')[1]

    ::Middleman::TemplateRenderer.cache.fetch(
      [:section_navigation, section_name].join(":")
    ) do
      # First, get all index pages under this section
      items = product_links(section, with_index: true)
      categories = {}

      # Remember dangling pages that are in a folder with no index page
      # We just render them in the first level navigation
      dangling_pages = []

      # Then search all index pages
      # to build the first level
      suffix = '/index'
      if args[:has_index_html] == false
        suffix = ''
      end

      # Since some menu elements have no index html file structure (e.g. API files)
      # we need to select those with another regex
      items
        .select { |entry|
          entry[:path].match?(%r{/#{section_name}/([^/]+)#{suffix}}) &&
          # Filter out the index page (e.g 'api/index')
          (!(args[:has_index_html] == false) || !entry[:path].end_with?('index'))
        }
        .each do |entry|
        category = entry[:resource].path.split('/')[1]
        if category == section_name
          category = entry[:resource].path.split('/')[2]
        end
        categories[category] = entry.merge(children: [])
      end

      # Then search other sub pages
      # to find the second level by looking for anything BUT
      # the index pages of children of this section
      items
        .select { |entry| entry[:path].match? %r{/#{section_name}/.+?/(?!index)} }
        .each do |entry|

        path_parts = entry[:resource].path.split('/')

        category = path_parts[1]
        if category == section_name
          category = entry[:resource].path.split('/')[2]
        end
        if categories[category]
          categories[category][:children] << entry
        else
          warn "Pages exist, but no index at #{section_name}/#{category} exists. Adding to dangling."
          dangling_pages << entry
        end
      end

      # Then return all sorted items
      sorter = args[:sorter] || :sort_by_priority
      sorted = send(sorter, categories.values + dangling_pages, args)

      sorted.each do |item|
        item[:children] = send(sorter, item[:children], args) if item[:children]
      end

      sorted
    end
  end

  def sort_by_priority(pages, args = {})
    prioritized_order = args[:prioritized_order] || []

    pages.sort_by do |entry|
      [prioritized_order.index(entry[:path]) || 1000, -entry[:priority], entry[:title]]
    end
  end

  ##
  # Lambda callback to be used by sidebar navigation to properly
  # create sort order
  def sort_by_release_date(pages, args = {})
    pages
      .sort_by { |entry| entry[:data].release_date }
      .reverse
  end
end
