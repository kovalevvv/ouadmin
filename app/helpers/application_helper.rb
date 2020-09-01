module ApplicationHelper

	def title
		if content_for?(:title)
      title_with_app_name(content_for :title)
    else
			title_with_app_name(t("#{ controller_path.tr('/', '.') }.#{ action_name }.title"))
		end
	end

	def title_with_app_name(title)
		"%s - %s" % [title, t('app.name')]
	end

end
