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
  def generate_section_navigation(section, prioritized_order = [])
    section_name = section.delete_prefix('/').chomp('/')
    result = []

    # First, get all items under this prefix
    items = product_links(section, with_index: true)
    categories = {}

    # Then search all index pages
    items
      .select { |entry| entry[:is_index] }
      .each do |entry|
      # Ignore the main index of this resource
      next if entry[:path] == "/#{section_name}/index"

      subpath = entry[:resource].path.split('/')[1]
      categories[subpath] = entry.merge(children: [])
    end

    # Then search all other pages
    items
      .reject { |entry| entry[:is_index] }
      .each do |entry|

      path_parts = entry[:resource].path.split('/')

      # Add to main if no subpath involved
      if path_parts.length <= 2
        result << entry
        next
      end

      subpath = path_parts[1]
      if categories[subpath]
        categories[subpath][:children] << entry
      else
        warn "Pages exist, but no index at #{section_name}/#{subpath} exists. Adding to main."
        result << entry
      end
    end

    # Then return all sorted items
    prioritized_order ||= []
    sort_array = ->(entry) { [prioritized_order.index(entry[:path]) || 1000, -entry[:priority], entry[:title]] }
    (categories.values + result)
      .sort_by(&sort_array)
      .map do |item|

      item[:children]&.sort_by!(&sort_array)

      item
    end
  end
end