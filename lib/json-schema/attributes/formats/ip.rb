require 'json-schema/attributes/format'
require 'ipaddr'
require 'socket'

module JSON
  class Schema
    class IPFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)
        error_type = RUBY_VERSION >= '3' ? IPAddr::InvalidAddressError : ArgumentError
        error_message = RUBY_VERSION >= '3' ? "invalid address: #{data}" : 'invalid address'
        begin
          ip = IPAddr.new(data)
        rescue error_type => e
          raise e unless e.message == error_message
        end

        family = ip_version == 6 ? Socket::AF_INET6 : Socket::AF_INET
        unless ip && ip.family == family
          error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv#{ip_version} address"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
        end
      end

      def self.ip_version
        raise NotImplementedError
      end
    end

    class IP4Format < IPFormat
      def self.ip_version
        4
      end
    end

    class IP6Format < IPFormat
      def self.ip_version
        6
      end
    end
  end
end
