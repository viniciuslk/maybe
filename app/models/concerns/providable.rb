# `Providable` serves as an extension point for integrating multiple providers.
# For an example of a multi-provider, multi-concept implementation,
# see: https://github.com/maybe-finance/maybe/pull/561

module Providable
  extend ActiveSupport::Concern

  class_methods do
    def security_prices_provider
      if ENV["MARKETSTACK_API_KEY"].present?
        marketstack_provider
      elsif ENV["SYNTH_API_KEY"].present?
        synth_provider
      end
    end

    def exchange_rates_provider
      synth_provider
    end

    def git_repository_provider
      Provider::Github.new
    end

    def synth_provider
      api_key = self_hosted? ? Setting.synth_api_key : ENV["SYNTH_API_KEY"]
      api_key.present? ? Provider::Synth.new(api_key) : nil
    end

    def marketstack_provider
      api_key = ENV["MARKETSTACK_API_KEY"]
      api_key.present? ? Provider::Marketstack.new(api_key) : nil
    end

    private
      def self_hosted?
        Rails.application.config.app_mode.self_hosted?
      end
  end
end
