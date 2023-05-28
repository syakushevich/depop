require 'telegram/bot'
require 'active_record'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::CallbackQuery
      if message.data == 'show_products'
        products = Product.from_last_day
        product_details = products.map { |product| "#{product.name}: #{product.price}" }.join("\n")
        bot.api.send_message(chat_id: message.from.id, text: "Products from the last day:\n#{product_details}")
      end
    when Telegram::Bot::Types::Message
      case message.text
      when '/start'
        kb = [
          [Telegram::Bot::Types::KeyboardButton.new(text: 'Show products from the last day')]
        ]
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}! Please send me a Depop product URL.", reply_markup: markup)
      when 'Show products from the last day'
        products = Product.from_last_day
        product_details = products.map { |product| "#{product.name}: #{product.price}" }.join("\n")
        bot.api.send_message(chat_id: message.chat.id, text: "Products from the last day:\n#{product_details}")
      else
        url = message.text
        product = Parser.parse(url)
        bot.api.send_message(chat_id: message.chat.id, text: "Product created: #{product.name} \n Condition: #{product.condition} \n Brand: #{product.brand} \n Size: #{product.size} \n Description: #{product.description}")
      end
    end
  end
end
