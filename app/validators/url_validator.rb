# frozen_string_literal: true

require 'net/http'

class UrlValidator < ActiveModel::EachValidator
  def url_exist?(url_string)
    uri = URI.parse(url_string)
    return false unless uri.is_a?(URI::HTTP)

    res = Net::HTTP.get_response(uri)

    return url_exist?(res['location']) if !res.is_a?(Net::HTTPNotModified) && res.is_a?(Net::HTTPRedirection)

    return !%w[4 5].include?(res.code[0]) if res.is_a?(Net::HTTPResponse)

    false
  rescue SocketError, URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid) unless url_exist?(value)
  end
end
