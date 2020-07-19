class Jekyll::MarkdownHeader < Jekyll::Converters::Markdown
    def convert(content)
      now = Time.now.to_i
      super.gsub(/<h(\d) id="(.*?)">/, "<h\\1 id=\"\\2\"><a class=\"heading-anchor\" aria-hidden=\"true\" href=\"#\\2\"><img src=\"/assets/icons/link.svg?#{now}\"></a>")
    end
end
