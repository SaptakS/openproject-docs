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
      "/#{path}"
    else
      "/#{lang}/#{path}"
    end
  end

  def localized_url(external_url, options = {})
    lang = options.fetch(:language, I18n.locale.to_s)
    external_url = external_url.chomp('/')

    if lang == 'en'
      external_url
    else
      if external_url == site_url() || external_url.include?("openproject")
        "#{external_url}/#{lang}"
      end
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