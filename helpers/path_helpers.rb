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