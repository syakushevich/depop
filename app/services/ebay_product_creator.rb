require 'net/http'
require 'uri'
require 'json'

class EbayProductCreator
  def self.call(product)
    new(product).call
  end

  def initialize(product)
    @product = product
  end

  def call
    # Step 1: Authenticate with eBay API
    access_token = get_access_token

    # Step 2: Construct the request payload
    payload = {
      title: @product.name,
      condition: @product.condition,
      description: @product.description,
      # ... fill out the rest of the payload based on the eBay's product creation API spec
    }.to_json

    # Step 3: Make a POST request to the eBay API
    uri = URI.parse('https://api.ebay.com/sell/inventory/v1/inventory_item') # replace with actual eBay API endpoint
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{access_token}")
    request.body = payload

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    # Step 4: Handle the response from eBay
    if response.code == '201'
      puts 'Product created successfully on eBay!'
    else
      puts "Failed to create product on eBay. Response code: #{response.code}. Response body: #{response.body}"
    end
  end

  private

  def get_access_token
    # Replace with your actual logic to get an access token from eBay API
    # You will need your eBay API keys for this step
    'your_ebay_api_access_token'
  end
end
