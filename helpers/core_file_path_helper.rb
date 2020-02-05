module CoreFilePathHelper
  def core_branch
    data.buildinfo&.branch || 'dev'
  end
  def edit_this_page_path(page = current_page)
    if core_path = (page.data&.source_path || find_core_path_of_page(page))
      "https://github.com/opf/openproject/blob/#{core_branch}/#{core_path}"
    else
      search_for_page(page)
    end
  end

  def find_core_path_of_page(page)
    return unless page.respond_to?(:target)

    if page.target.include?('localizable/')
      path = get_source_path(page)
      "help/#{path}"
    end
  end

  ##
  # source path
  def get_source_path(page)
    page.path
      .gsub('index.html', 'README.md')
      .gsub('.html', '.md')
  end

  ##
  # Find the core name or folder of page
  def search_for_page(page)
    source_path = get_source_path(page)
    last_part = source_path.split('/').last

    page_name =
      if last_part == 'index.md'
        # Return the folder name
        source_path.split('/')[-2]
      else
        # Return the file itself
        last_part
      end

    params = { q: page_name }
    "https://github.com/opf/openproject/search?#{params.to_param}"
  end
end