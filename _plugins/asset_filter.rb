module Jekyll
  module AssetFilter
    def asset_url(input)
      "/#{input}?#{Time.now.to_i}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)
