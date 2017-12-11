require "logman/version"
require "logman/logger"

require "logger"

module Logman
  DEFAULT_LOGGER = Logman::Logger.new

  def self.fatal(message, metadata = {})
    DEFAULT_LOGGER.fatal(message, metadata)
  end

  def self.error(message, metadata = {})
    DEFAULT_LOGGER.error(message, metadata)
  end

  def self.warn(message, metadata = {})
    DEFAULT_LOGGER.warn(message, metadata)
  end

  def self.info(message, metadata = {})
    DEFAULT_LOGGER.info(message, metadata)
  end

  def self.debug(message, metadata = {})
    DEFAULT_LOGGER.debug(message, metadata)
  end
end
