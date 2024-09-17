# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conferences.
      #
      class ConferencesController < Decidim::Conferences::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminBreadcrumb

        helper_method :current_conference, :current_participatory_space, :deleted_collection
        layout "decidim/admin/conferences"
        include Decidim::Conferences::Admin::Filterable

        def index
          enforce_permission_to :read, :conference_list
          @conferences = filtered_collection.not_deleted
        end

        def new
          enforce_permission_to :create, :conference
          @form = form(ConferenceForm).instance
        end

        def create
          enforce_permission_to :create, :conference
          @form = form(ConferenceForm).from_params(params)

          CreateConference.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences.create.success", scope: "decidim.admin")
              redirect_to conferences_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conferences.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :conference, conference: current_conference
          @form = form(ConferenceForm).from_model(current_conference)
          render layout: "decidim/admin/conference"
        end

        def update
          enforce_permission_to :update, :conference, conference: current_conference
          @form = form(ConferenceForm).from_params(
            conference_params,
            conference_id: current_conference.id
          )

          UpdateConference.call(@form, current_conference) do
            on(:ok) do |conference|
              flash[:notice] = I18n.t("conferences.update.success", scope: "decidim.admin")
              redirect_to edit_conference_path(conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conferences.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/conference"
            end
          end
        end

        def copy
          enforce_permission_to :create, :conference
        end

        def soft_delete
          enforce_permission_to :soft_delete, :conference, conference: current_conference
          Decidim::Commands::SoftDeleteResource.call(current_conference, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences.soft_delete.success", scope: "decidim.admin")
              redirect_to conferences_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("conferences.soft_delete.invalid", scope: "decidim.admin")
              redirect_to conferences_path
            end
          end
        end

        def restore
          enforce_permission_to :restore, :conference, conference: current_conference
          Decidim::Commands::RestoreResource.call(current_conference, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences.restore.success", scope: "decidim.admin")
              redirect_to conferences_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("conferences.restore.invalid", scope: "decidim.admin")
              redirect_to conferences_path
            end
          end
        end

        def deleted
          enforce_permission_to :read, :conference_list
        end

        private

        def current_conference
          @current_conference ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_conference

        def collection
          @collection ||= OrganizationConferences.new(current_user.organization).query
        end

        def conference_params
          { id: params[:slug] }.merge(params[:conference].to_unsafe_h)
        end

        def deleted_collection
          @deleted_collection ||= filtered_collection.trashed
        end
      end
    end
  end
end
