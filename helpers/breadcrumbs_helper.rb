module BreadcrumbsHelper

  ##
  # Iterate over the middleman parent pages
  # to build a breadcrumb
  def build_breadcrumbs
    [current_page].tap do |hierarchy|
      hierarchy.unshift hierarchy.first.parent while hierarchy.first.parent
    end
  end

  ##
  # Build or derive the title in the breadcrumb
  def breadcrumb_title(page)
    title = page.data.title || derive_title(page)

    # Remove the API generated permalink
    # as this would otherwise show in the output
    title.gsub('¶', '')
  end
end