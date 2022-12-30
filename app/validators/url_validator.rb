# frozen_string_literal: true

require 'net/http'

# URL validator for urls from Model should valid, be able to redirect or response success
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid) unless url_valid?(value)
  end

  private

  def default_host
    Rails.application.routes.default_url_options[:host]
  end

  def uri_response(url_string)
    uri = uri(url_string)
    return false unless uri

    if PublicSuffix.valid?(uri.host, default_rule: nil) && !%w[example.com bit.ly localhost].include?(uri.host)
      return true
    end

    Rails.cache.fetch("url_response:#{url_string}") { Timeout.timeout(1) { Net::HTTP.get_response(uri) } }
  end

  def handle_response(uri_response)
    case uri_response
    when true
      true
    when Net::HTTPSuccess, Net::HTTPNotModified
      true
    when Net::HTTPRedirection
      url_valid?(uri_response['location'])
    else
      false
    end
  end

  def url_valid?(url_string)
    url_regexp = %r{\A(http|https)://[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(/.*)?\z}ix

    return false unless url_string =~ url_regexp ? true : false

    uri_response = uri_response(url_string)
    handle_response(uri_response)
  rescue Timeout::Error
    true
  end

  def uri(url_string)
    uri = Rails.cache.fetch("uri_from_url:#{url_string}") do
      Addressable::URI.parse(url_string)
    end
    return uri if uri.is_a?(Addressable::URI) && uri.host != default_host

    false
  end
end
