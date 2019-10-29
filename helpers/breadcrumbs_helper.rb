module BreadcrumbsHelper
  def build_breadcrumbs
    [current_page].tap do |hierarchy|
      hierarchy.unshift hierarchy.first.parent while hierarchy.first.parent
    end
  end
end