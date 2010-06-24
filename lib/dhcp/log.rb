module DHCP::Log
  def logger
    if defined? RAILS_DEFAULT_LOGGER
      # If we are running as a library in a rails app then use the provided logger
      RAILS_DEFAULT_LOGGER
    else
      # We must make our own ruby based logger if we are a standalone proxy server
      require 'logger'
      # We keep the last 6 1MB log files
      return Logger.new("/tmp/dhcp-proxy", 6, 1024*1024)
    end
  end
end
