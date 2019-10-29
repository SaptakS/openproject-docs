module BreadcrumbsHelper
  def build_breadcrumbs
    [current_page].tap do |hierarchy|
      hierarchy.unshift hierarchy.first.parent while hierarchy.first.parent
    end
  end

  def breadcrumb_title(page)
    title = page.data.title || derive_title(page)

    # Remove the API generated permalink
    # as this would otherwise show in the output
    title.gsub('¶', '')
  end
end