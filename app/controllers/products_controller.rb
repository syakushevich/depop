class ProductsController < ApplicationController
  def index
    @products = Product.all
    render json: @products
  end

  def create
    @product = Parser.parse(params[:url])
    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def telegram_webhook
    token = ENV['TELEGRAM_BOT_TOKEN']
    Telegram::Bot::Client.run(token) do |bot|
      bot.listen do |message|
        case message.text
        when '/start'
          kb = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Show products from the last day', callback_data: 'show_products')
          ]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}!", reply_markup: markup)
        when 'show_products'
          # Here you can call your index action logic to get all products from the last day
          # Then send a message back to the user with the product details
        else
          url = message.text
          # Here you can call your create action logic to parse the webpage and save the product
          # Then send a message back to the user with the product details
        end
      end
    end
  end
end
