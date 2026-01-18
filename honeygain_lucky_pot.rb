# frozen_string_literal: true

#!/usr/bin/env ruby
require 'ferrum'
require 'logger'
require 'rufus-scheduler'

class SilentLogger < Logger
  def error(msg = nil, level = nil)
    warn "Rufus error: #{msg}" if msg && msg.to_s.include?('ProcessTimeoutError')
  end
end

class HoneygainAutomation
  def initialize(email, password)
    @email = email
    @password = password
    @logger = Logger.new($stdout)
    @logger.level = Logger::INFO
  end

  def click_lucky_pot
    @logger.info 'Starting Lucky Pot automation...'

    browser = Ferrum::Browser.new(
      headless: true,
      window_size: [1920, 1080],
      timeout: 60,
      process_timeout: 30,
      browser_options: {
        'no-sandbox' => nil,
        'disable-dev-shm-usage' => nil,
        'disable-gpu' => nil,
        'disable-extensions' => nil
      }
    )

    max_retries = 2
    retry_count = 0

    begin
      browser.go_to('https://dashboard.honeygain.com/')
      sleep 3

      # Login
      @logger.info 'Logging in...'
      browser.fill_in('input[name="email"]', @email)
      browser.fill_in('input[name="password"]', @password)
      browser.keyboard.press('Enter')  # Plus fiable que down(:Enter)

      # Wair login + dashboard
      browser.wait_for_selector('#dashboard', timeout: 30)  # Sélecteur dashboard Honeygain
      sleep 2

      # Lucky Pot
      @logger.info 'Searching Lucky Pot...'
      if browser.wait_for_xpath("//button[.//span[contains(text(), 'Open Lucky Pot')]]", timeout: 15)
        button = browser.at_xpath("//button[.//span[contains(text(), 'Open Lucky Pot')]]")
        button.click
        @logger.info "✓ Lucky Pot opened at #{Time.now}"
      else
        @logger.warn 'Lucky Pot not available (limit reached?)'
      end

    rescue Ferrum::ProcessTimeoutError => e
      retry_count += 1
      if retry_count <= max_retries
        @logger.warn "Process timeout, retry #{retry_count}/#{max_retries}"
        sleep 5
        retry
      else
        raise e
      end
    rescue Ferrum::TimeoutError, Ferrum::NodeNotFoundError => e
      @logger.warn "Ferrum timeout/select error: #{e.message}"
    rescue StandardError => e
      @logger.error "Unexpected error: #{e.message}"
    ensure
      browser&.quit
    end
  end
end

# Checks env
unless ENV['HONEYGAIN_EMAIL'] && ENV['HONEYGAIN_PASSWORD']
  abort "Erreur: Set HONEYGAIN_EMAIL and HONEYGAIN_PASSWORD"
end

# Logger global propre
$stdout.sync = true
logger = Logger.new($stdout)
logger.info 'Honeygain Lucky Pot scheduler started.'

scheduler = Rufus::Scheduler.new(
  frequency: 0.5,  # Check job toutes les 0.5s
  pause: false
)

scheduler.every '2h' do
  begin
    automation = HoneygainAutomation.new(
      ENV['HONEYGAIN_PASSWORD'],
      ENV['HONEYGAIN_EMAIL']  # Tu avais inversé !
    )
    automation.click_lucky_pot
  rescue => e
    logger.error "Job failed: #{e.message}"
  end
end

scheduler.join
