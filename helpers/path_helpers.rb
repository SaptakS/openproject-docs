require 'nokogiri'

module PathHelpers
  def pages_for_product(path, with_index: false)
    sitemap.resources.select do |resource|
      rpath = resource.path

      rpath.end_with?('.html') &&
        (with_index || !rpath.end_with?('index.html')) &&
        rpath.start_with?(path)
    end
  end

  def product_links(path, with_index: false)
    pages_for_product(path, with_index: with_index)
      .map do |resource|
      path = '/' + resource.path.gsub(/\.html$/, '').delete_prefix('/')

      {
        resource: resource,
        is_index: path.end_with?('index'),
        title: resource.metadata[:page][:title] || resource.data.title || derive_title(resource),
        path: path,
        url: path.chomp('/index')
      }
    end
  end

  def derive_title(page = current_page)
    rendered = Nokogiri::HTML(page.render({layout: false}))

    headline = rendered.css('h1,h2').first

    if headline
      headline.text.strip
    else
      page.url.split(/\//).last.titleize
    end
  end
end