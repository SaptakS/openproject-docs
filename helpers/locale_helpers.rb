module LocaleHelpers
  def site_url
    (config[:site_url] || '').chomp('/')
  end

  def root_path
    "#{site_url}/"
  end

  def translate_path_to_target_lang(path, target_lang)
    path = path.delete_prefix('/')
    new_path = ""
    path.split("/").each do |chunk|
      untranslated_path = t(:paths).key(chunk)
      if untranslated_path != nil
        translated = I18n.t("paths.#{untranslated_path}", locale: target_lang, default: untranslated_path)
        new_path = "#{new_path}/#{translated}"
      else
        new_path = "#{new_path}/#{chunk}"
      end
    end
    new_path
  end

  def translate_nav_path(path)
    path = path.delete_prefix('/')
    new_path = ""
    path.split("/").each do |chunk|
      translated = I18n.t("paths.#{chunk}", locale: I18n.locale.to_s, default: chunk)
      new_path = "#{new_path}/#{translated}"
    end
    new_path
  end

  def localized_path(path, options = {})
    path = path.delete_prefix('/')
    lang = options.fetch(:language, I18n.locale.to_s)

    if lang == 'en'
      "#{translate_nav_path(path)}"
    else
      "/#{lang}#{translate_nav_path(path)}"
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
      translate_path_to_target_lang(url, target_lang)
    else
      "#{site_url}/#{target_lang}#{translate_path_to_target_lang(url, target_lang)}"
    end
  end
end