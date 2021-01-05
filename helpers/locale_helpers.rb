module LocaleHelpers
  def site_url
    (config[:site_url] || '').chomp('/')
  end

  def root_path
    "#{site_url}/"
  end

  def localized_path(path, options = {})
    path = path.delete_prefix('/')
    lang = options.fetch(:language, I18n.locale.to_s)

    if lang == 'en'
      "#{site_url}/#{path}"
    else
      "#{site_url}/#{lang}/#{path}"
    end
  end

  def switch_language_path(target_lang)
    current_lang = I18n.locale.to_s
    url = current_page.url.gsub("/#{current_lang}/", '/')

    if target_lang == 'en'
      # Link to the current page with english
      url
    else
      "#{site_url}/#{target_lang}#{url}"
    end
  end
end