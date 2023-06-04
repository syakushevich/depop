require 'telegram/bot'
require 'active_record'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

product_body = lambda do |product|
  "Product:\nName: #{product.name}\nLink: #{product.link}\nPrice: #{product.price}\nSize: #{product.size}\nCountry: #{product.country}\nBrand: #{product.brand}\nColor: #{product.color}\nCondition: #{product.condition}\nDescription: #{product.description}"
end

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::CallbackQuery
      product = Product.find(message.data)
      bot.api.send_message(chat_id: message.from.id, text: product_body.call(product))
      media_group = product.image_urls.map do |url|
        Telegram::Bot::Types::InputMediaPhoto.new(media: url)
      end
      bot.api.send_media_group(chat_id: message.from.id, media: media_group)
    when Telegram::Bot::Types::Message
      case message.text
      when '/start'
        kb = [
          [Telegram::Bot::Types::KeyboardButton.new(text: 'Show last 10 products')],
          [Telegram::Bot::Types::KeyboardButton.new(text: 'Add new depop product')]
        ]
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}!", reply_markup: markup)
      when 'Show last 10 products'
        products = Product.last(10)
        kb = products.map do |product|
          [Telegram::Bot::Types::InlineKeyboardButton.new(text: product.name, callback_data: product.id.to_s)]
        end
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        bot.api.send_message(chat_id: message.chat.id, text: "Choose a product:", reply_markup: markup)
      when 'Add new depop product'
        bot.api.send_message(chat_id: message.chat.id, text: "Please send me a Depop product URL.")
      else
        url = message.text
        product = Parser.parse(url)
        # EbayProductCreator.call(product)
        bot.api.send_message(chat_id: message.chat.id, text: product_body.call(product))
        media_group = product.image_urls.map do |url|
          Telegram::Bot::Types::InputMediaPhoto.new(media: url)
        end
        bot.api.send_media_group(chat_id: message.chat.id, media: media_group)
      end
    end
  end
end
