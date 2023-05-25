require 'open-uri'
require 'nokogiri'

module Parser
  def self.parse(url)
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    name = doc.css('h1[class*="ProductDetailsSticky"]').text.strip
    price = doc.css('div[class*="ProductDetailsStickystyles__Wrapper"] p[class*="Pricestyles__FullPrice"]').text.strip
    country = doc.css('div[class*="styles__StyledBio"] p[class*="styles__Location"]').text.strip
    description = doc.css('p[data-testid="product__description"][class*="styles__Container"]').text.strip

    image_urls = doc.css('div[class*="styles__Desktop"] img').map { |img| img['src'] }

    details = doc.css('div[class*="styles__Details"] td').map(&:text)
    size = details[0].strip
    brand = details[1].strip
    condition = details[2].strip
    material = details[3].strip
    style = details[4].strip
    color = details[5].strip

    @product = Product.new(name: name, price: price, country: country, size: size, brand: brand, description: description,
                           condition: condition, material: material, style: style, color: color, image_urls: image_urls)
  end
end
