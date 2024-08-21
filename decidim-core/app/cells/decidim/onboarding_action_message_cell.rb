# frozen_string_literal: true

module Decidim
  # This cell renders an announcement of pending onboarding action
  # if exists for a user
  #
  # The `model` is expected to be a user
  #
  class OnboardingActionMessageCell < Decidim::ViewModel
    include ActiveLinkTo

    alias user model

    def show
      return if is_active_link?(onboarding_path)
      return unless onboarding_manager.valid?
      return unless onboarding_manager.pending_action?

      render :show
    end

    private

    def onboarding_path
      decidim_verifications.first_login_authorizations_path
    end

    def onboarding_manager
      @onboarding_manager ||= OnboardingManager.new(user)
    end

    def message_text
      t(
        "cta_html",
        scope: "decidim.onboarding_action_message",
        path: onboarding_path,
        action: onboarding_manager.action,
        resource_name: onboarding_manager.model_name.human.downcase,
        resource_title: translated_attribute(onboarding_manager.model.title)
      )
    end

    def info_icon
      icon("information-line")
    end

    def close_icon
      icon("close-line")
    end
  end
end