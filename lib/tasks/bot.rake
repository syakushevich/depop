namespace :bot do
  desc "Run Telegram bot"
  task run: :environment do
    require_relative '../../app/services/bot'
  end
end
