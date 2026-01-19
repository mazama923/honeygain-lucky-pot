#!/usr/bin/env ruby
require 'ferrum'
require 'logger'
require 'rufus-scheduler'

class HoneygainAutomation
  def initialize(email, password)
    @email = email
    @password = password
    @logger = Logger.new($stdout)
    @logger.level = Logger::INFO
  end

  def click_lucky_pot
    @logger.info 'Starting automation with Ferrum...'

    browser = Ferrum::Browser.new(
      headless: true,
      window_size: [1920, 1080],
      timeout: 30
    )

    begin
      browser.go_to('https://dashboard.honeygain.com/')
      sleep 5

      # Login
      @logger.info 'Logging in...'
      browser.at_css('input[name="email"]').focus.type(@email)
      sleep 1
      browser.at_css('input[name="password"]').focus.type(@password)
      sleep 1
      browser.keyboard.down(:Enter)

      sleep 3
      browser.network.wait_for_idle

      # wait and click Lucky Pot
      @logger.info 'Searching for Lucky Pot...'
      lucky_pot = browser.at_xpath("//button[.//span[contains(., 'Open Lucky Pot')]]")
      if lucky_pot
        lucky_pot.click
        @logger.info "✓ Lucky Pot clicked at #{Time.now}"
      else
        @logger.warn 'Lucky Pot button not available (maybe daily limit or not enough bandwidth)'
      end
    rescue StandardError => e
      @logger.error "Error: #{e.message}"
      @logger.error e.backtrace.join("\n") if e.backtrace
    ensure
      browser.quit
    end
  end
end

unless ENV['HONEYGAIN_EMAIL'] && ENV['HONEYGAIN_PASSWORD']
  abort "Erreur: HONEYGAIN_EMAIL or HONEYGAIN_PASSWORD not define"
end

scheduler = Rufus::Scheduler.new

scheduler.every '2h' do
  automation = HoneygainAutomation.new(
    ENV['HONEYGAIN_EMAIL'],
    ENV['HONEYGAIN_PASSWORD']
  )
  automation.click_lucky_pot
end

@logger = Logger.new($stdout)
@logger.info 'Honeygain scheduler started. Press Ctrl+C to stop.'

scheduler.join
