module CoreHelper
  include CommentsHelper
  include InterfaceHelper
  include AbuseHelper
  include UsersHelper
  include SearchHelper
  include RatesHelper
  include WillPaginate::ViewHelpers 
  include I18nHelper
  include VotesHelper
   
  
  def config
    Tog::Config
  end

  def inject_js
    @javascripts.uniq.collect{ |js|
      javascript_include_tag js
    }.join("\n")
  end

  def inject_css
    @stylesheets.uniq.collect{ |css|
      stylesheet_link_tag css
    }.join("\n")
  end

  def inject_autodiscovery
    @feeds.uniq.collect{ |feed|
      auto_discovery_link_tag feed[0], feed[1], feed[2]
    }.join("\n")
  end

  def include_stylesheet(css)
    @stylesheets << css
  end

  def include_javascript(js)
    @javascripts << js
  end

  def include_autodiscovery(type = :rss, url_options = {}, tag_options = {})
    @feeds << [type, url_options, tag_options]
  end

  def clean(url)
    uri = URI.parse(url)
    uri.path.gsub(%r{/+}, '/').gsub(%r{/$}, '')
  end
  
  def will_paginate_with_i18n(collection, options = {})
    will_paginate_without_i18n(collection, options.merge(:previous_label => I18n.t("will_paginate.previous"), :next_label => I18n.t("will_paginate.next") ))
  end
  alias_method_chain :will_paginate, :i18n

  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] ||
            (collection.empty?? I18n.t("will_paginate.entry_name") : collection.first.class.human_name)

    I18n.t("will_paginate.page_entries_info",
           :count => collection.size,
           :entry_name => (collection.size == 1) ? entry_name : entry_name.pluralize,
           :start => collection.offset.succ,
           :end => collection.offset + collection.size,
           :total => collection.total_entries)
  end
  
  def rich_text_area(obj, field, options = {})    
    options[:toolbarSet] ||= 'Basic'
    base_fck_code=fckeditor_textarea obj, field,  options
    
    options[:custom_configurations_file] ||= '/tog_core/javascripts/fck_public_config.js?1' #default config included for aspsocial editors   
    base_fck_code.sub!(/oFCKeditor.Config\['CustomConfigurationsPath'\].*/,"oFCKeditor.Config['CustomConfigurationsPath'] = '#{options[:custom_configurations_file]}';")           
    
    base_fck_code    
  end
  
  def image_for_rich_text_area(obj, field)
    link_to_function 'insert image' do |page|
      page.alert fckeditor_element_id(obj,field)
    end  
  end
end
