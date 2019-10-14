require 'nokogiri'

module PathHelpers
  def pages_for_product(path)
    sitemap.resources.select do |resource|
      rpath = resource.path

      rpath.end_with?('.html') &&
        !rpath.end_with?('index.html') &&
        rpath.start_with?(path)
    end
  end

  def product_links(path)
    pages_for_product(path)
      .map do |resource|
      {
        title: resource.metadata[:page][:title] || resource.data.title || derive_title(resource),
        path: resource.path.gsub(/\.html$/, '')
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