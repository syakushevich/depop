require 'open-uri'
require 'nokogiri'
require 'openai'

SAMPLE_DESCRIPTION = " Rare Camel leather bomber jacket.

    Size large. Looks dreamy oversized.

    100% genuine leather flight style aviator bomber jacket. This jacket is drippy as F*#k mate. One of those genuinely rare and unique finds you don’t come across too often. None others available on the internet.

    It has pockets inside and out.

    Please check the measurements below -

    Length- 28.5 inches
    Pit to pit- 25.5 inches

    🧵What’s the condition?! - fantastic overall condition- minor faults to note- the original zipper pull has gone and has been replaced with a key ring- maybe you want to spice it up as you see fit. Also a small tear to the lining inside. The exterior is in excellent vintage condition with no obvious defects.

    🌟We pride ourselves on quality over quantity"

OpenAI.configure { |config| config.access_token = ENV['OPEN_AI_SECRET'] }

class Parser
  def self.parse(url)
    new.parse(url)
  end

  def parse(url)
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    name = doc.css('h1[class*="ProductDetailsSticky"]').text.strip
    country = doc.css('div[class*="styles__StyledBio"] p[class*="styles__Location"]').text.strip
    size = doc.css('div[class*="styles__Details"] tr[data-testid="product__singleSize"] td').text.strip
    brand = doc.css('div[class*="styles__Details"] a').text.strip
    condition = doc.css('div[class*="styles__Details"] td[data-testid="product__condition"]').text.strip
    style = doc.css('div[class*="styles__Details"] tr[data-testid="product__style"] td').text.strip
    color = doc.css('div[class*="styles__Details"] td[data-testid="product__colour"]').text.strip
    image_urls = doc.css('div[class*="styles__Desktop"] img').map { |img| img['src'] }

    # Price logic
    parced_price = doc.css('div[class*="ProductDetailsStickystyles__Wrapper"] p[class*="Pricestyles__FullPrice"]').text.strip
    price = increase_price(parced_price).to_i

    # Description logic
    parsed_description = doc.css('p[data-testid="product__description"][class*="styles__Container"]').text.strip
    description = generate_description(parsed_description)

    @product = Product.create(name: name, price: price, country: country, size: size, brand: brand, description: description,
                              condition: condition, style: style, color: color, image_urls: image_urls)
  end

  def generate_description(parsed_description)
    prompt = "I have this item description: \n```#{parsed_description}```\n Can you rewrite it, in the style of this advertisement: \n```#{SAMPLE_DESCRIPTION}```"
    client = OpenAI::Client.new
    response = client.chat(parameters: { model: "gpt-3.5-turbo", messages: [{ role: "user", content: prompt}], temperature: 0.7 })
    response.dig('choices', 0, 'message', 'content')
  end

  def increase_price(price)
    increase_by_value = price + 10
    increase_by_percent = price * 1.10

    (increase_by_value > increase_by_percent) ? increase_by_value : increase_by_percent
  end
end
