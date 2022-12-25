# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class UrlControllerTest < ActionDispatch::IntegrationTest
      test 'input valid original_url should get shortened url encode' do
        post encode_api_v1_url_index_url, params: { url: { original_url: urls(:react).original_url } }
        assert_response :success
        assert_includes response.body, urls(:react).shortened
      end

      test 'input valid shortened_url should get original url decoded' do
        post decode_api_v1_url_index_url, params: { url: { shortened_url: urls(:react).shortened } }
        assert_response :success
        assert_includes response.body, urls(:react).original_url
      end

      test 'input invalid host should get error code' do
        post decode_api_v1_url_index_url, params: { url: { shortened_url: "https://google.com/#{urls(:react).slug}" } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Shorten URL is not valid'
      end
    end
  end
end
