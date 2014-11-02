require 'rbconfig'
require 'uri'

module URI

  # Ruby does not have built-in support for filesystem URIs, and definitely does not have built-in support for
  # using open-uri with filesystem URIs. At least until this issue is closed https://bugs.ruby-lang.org/issues/8544
  class File < Generic

    COMPONENT = [
          :scheme,
          :path,
          :fragment,
          :host
        ].freeze

    def initialize(*arg)
      super(*arg)
      # this logic to set the host to "" causes file schemes with UNC to break
      # so don't do it on windows platforms
      is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
      @host = "" unless is_windows
    end

    def self.build(args)
      tmp = Util::make_components_hash(self, args)
      return super(tmp)
    end

    def open(*rest, &block)
      ::File.open(self.path.gsub('%20', ' '), *rest, &block)
    end

    @@schemes['FILE'] = File
  end
end
