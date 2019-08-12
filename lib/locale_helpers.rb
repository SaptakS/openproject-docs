module LocaleHelpers
  def localized_path(path, options = {})
    lang = options.fetch(:language, I18n.locale.to_s)

    if lang == 'en'
      "/#{path}"
    else
      "/#{lang}/#{path}"
    end
  end

  def switch_language_path(target_lang)
    current_lang = I18n.locale.to_s
    url = current_page.url.gsub("#{current_lang}/", '')

    if target_lang == 'en'
      # Link to the current page with english
      url
    else
      "/#{target_lang}#{current_page.url}"
    end
  end
end