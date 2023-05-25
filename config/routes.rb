Rails.application.routes.draw do
  resources :products, only: [:index, :create]

  # post 'telegram_webhook', to: 'products#telegram_webhook'
end
