require 'action_view'
require 'action_view/helpers'

module DateHelper
  include ActionView::Helpers::DateHelper

  def relative_date(date)
    time_ago_in_words(date)
  end
end