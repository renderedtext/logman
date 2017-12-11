require "logman/version"
require "logger"

module Logman
  DEFAULT_LOGGER = Logger.new(STDOUT)
  DEFAULT_LOGGER.formatter = proc do |severity, datetime, progname, msg|
    event = { :level => severity[0].upcase, :time => datetime }.merge(msg)

    "#{Logman.format(event)}\n"
  end

  def self.fatal(message)
    DEFAULT_LOGGER.fatal(:event => message)
  end

  def self.error(message)
    DEFAULT_LOGGER.error(:event => message)
  end

  def self.warn(message)
    DEFAULT_LOGGER.warn(:event => message)
  end

  def self.info(message)
    DEFAULT_LOGGER.info(:event => message)
  end

  def self.debug(message)
    DEFAULT_LOGGER.debug(:event => message)
  end

  def self.format(event_hash)
    event_hash.map { |key, value| "#{key}='#{value}'" }.join(" ")
  end
end
