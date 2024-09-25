# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory processes.
      #
      class ParticipatoryProcessesController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminContext
        include Decidim::ParticipatoryProcesses::Admin::Filterable

        add_breadcrumb_item_from_menu :admin_participatory_process_menu, only: :show

        participatory_space_admin_layout only: [:edit]

        helper ProcessGroupsForSelectHelper
        helper Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessHelper

        helper_method :current_participatory_process, :current_participatory_space, :process_group, :deleted_collection

        layout "decidim/admin/participatory_processes"

        def index
          enforce_permission_to :read, :process_list
          @participatory_processes = filtered_collection.not_deleted
        end

        def new
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessForm).instance
        end

        def create
          enforce_permission_to :create, :process
          @form = form(ParticipatoryProcessForm).from_params(params)

          CreateParticipatoryProcess.call(@form) do
            on(:ok) do |participatory_process|
              flash[:notice] = I18n.t("participatory_processes.create.success", scope: "decidim.admin")
              redirect_to participatory_process_steps_path(participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :process, process: current_participatory_process
          @form = form(ParticipatoryProcessForm).from_model(current_participatory_process)
          render layout: "decidim/admin/participatory_process"
        end

        def update
          enforce_permission_to :update, :process, process: current_participatory_process
          @form = form(ParticipatoryProcessForm).from_params(
            participatory_process_params,
            process_id: current_participatory_process.id
          )

          UpdateParticipatoryProcess.call(@form, current_participatory_process) do
            on(:ok) do |participatory_process|
              flash[:notice] = I18n.t("participatory_processes.update.success", scope: "decidim.admin")
              redirect_to edit_participatory_process_path(participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes.update.error", scope: "decidim.admin")
              render :edit, layout: "decidim/admin/participatory_process"
            end
          end
        end

        def copy
          enforce_permission_to :create, Decidim::ParticipatoryProcess
        end

        def soft_delete
          enforce_permission_to :soft_delete, :process, process: current_participatory_process

          Decidim::Commands::SoftDeleteResource.call(current_participatory_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_processes.soft_delete.success", scope: "decidim.admin")
              redirect_to participatory_processes_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("participatory_processes.soft_delete.invalid", scope: "decidim.admin")
              redirect_to participatory_processes_path
            end
          end
        end

        def restore
          enforce_permission_to :restore, :process, process: current_participatory_process

          Decidim::Commands::RestoreResource.call(current_participatory_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_processes.restore.success", scope: "decidim.admin")
              redirect_to manage_trash_participatory_processes_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("participatory_processes.restore.invalid", scope: "decidim.admin")
              redirect_to manage_trash_participatory_processes_path
            end
          end
        end

        def manage_trash
          enforce_permission_to :manage_trash, :process
          render :manage_trash
        end

        private

        def process_group
          @process_group ||= ParticipatoryProcessGroup.find_by(id: ransack_params[:decidim_participatory_process_group_id_eq], organization: current_organization)
        end

        def collection
          @collection ||= ParticipatoryProcessesWithUserRole.for(current_user)
        end

        def deleted_collection
          @deleted_collection ||= filtered_collection.trashed
        end

        def current_participatory_process
          @current_participatory_process ||= collection.where(slug: params[:slug]).or(
            collection.where(id: params[:slug])
          ).first
        end

        alias current_participatory_space current_participatory_process

        def participatory_process_params
          { id: params[:slug] }.merge(params[:participatory_process].to_unsafe_h)
        end
      end
    end
  end
end
