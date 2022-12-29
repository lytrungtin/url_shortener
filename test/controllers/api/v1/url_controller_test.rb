# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class UrlControllerTest < ActionDispatch::IntegrationTest
      test 'encode valid original_url should get shortened url encode' do
        post encode_api_v1_url_index_url, params: { url: { original_url: 'https://www.google.com/?q=RailsTutorial' } }
        assert_response :success
        assert_includes response.body, 'https://www.google.com/?q=RailsTutorial'
        assert_includes response.body, Url.last.shortened
      end

      test 'encode with original_url 301 status should get shortened url encode' do
        post encode_api_v1_url_index_url, params: { url: { original_url: 'http://www.fb.com/' } }
        assert_response :success
        assert_includes response.body, 'http://www.fb.com/'
        assert_includes response.body, Url.last.shortened
      end

      test 'encode invalid empty original_url params should get error code' do
        post encode_api_v1_url_index_url, params: { url: { original_url: {} } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Original URL is required'
      end

      test 'encode invalid host should get error code' do
        post encode_api_v1_url_index_url, params: { url: { original_url: urls(:react).shortened } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Original url is invalid'
      end

      test 'encode invalid format original_url should get error code' do
        post encode_api_v1_url_index_url, params: { url: { original_url: 'something_wrong' } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Original url is invalid'
      end

      test 'decode valid shortened_url should get original url decoded' do
        urls(:react).save!
        post decode_api_v1_url_index_url, params: { url: { shortened_url: urls(:react).shortened } }
        assert_response :success
        assert_includes response.body, urls(:react).shortened
        assert_includes response.body, urls(:react).original_url
      end

      test 'decode invalid empty shortened_url params should get error code' do
        post decode_api_v1_url_index_url, params: { url: { shortened_url: {} } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Shorten URL is required'
      end

      test 'decode invalid host should get error code' do
        post decode_api_v1_url_index_url, params: { url: { shortened_url: "https://google.com/#{urls(:react).slug}" } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Shorten URL is not valid'
      end

      test 'decode invalid format shortened_url should get error code' do
        post decode_api_v1_url_index_url, params: { url: { shortened_url: 'something wrong' } }
        assert_response :unprocessable_entity
        assert_includes response.body, 'Shorten URL is not valid'
      end
    end
  end
end
