module Jekyll
  module RelatedPagesFilter
    def related_pages(page)
      page_categories = page['categories']
      pages = @context.registers[:site].posts.docs.reject do |other_page| 
        other_page.data['title'] == page['title'] 
      end
      pages.map do |page|
        [page, common_categories(page, page_categories)]
      end.reject { |x| x[1] == 0 }.sort_by { |x| 0 - x[1] }.map { |x| x[0] }
    end


    private

    def common_categories(page, page_categories)
      page.data['categories'].reduce(0) do |count, category|
        if page_categories.include? category
          count + 1
        else
          count
        end
      end    
    end
  end
end

Liquid::Template.register_filter(Jekyll::RelatedPagesFilter)

