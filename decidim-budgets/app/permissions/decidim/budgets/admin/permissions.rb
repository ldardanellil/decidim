# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :budget
            case permission_action.action
            when :create, :read, :export, :manage_trash
              allow!
            when :update, :soft_delete
              toggle_allow(budget)
            when :delete, :publish, :unpublish
              toggle_allow(budget && budget.projects.empty?)
            when :restore
              permission_action.allow! if budget.present? && budget.trashed?
            end
          when :project, :projects
            case permission_action.action
            when :create, :import_proposals, :project_category, :manage_trash
              permission_action.allow!
            when :update, :destroy, :soft_delete
              permission_action.allow! if project.present?
            when :restore
              permission_action.allow! if project.present? && project.trashed?
            end
          when :order
            case permission_action.action
            when :remind
              permission_action.allow!
            end
          when :project_category, :project_scope, :project_selected
            permission_action.allow!
          end

          permission_action
        end

        private

        def budget
          @budget ||= context.fetch(:budget, nil)
        end

        def project
          @project ||= context.fetch(:project, nil)
        end
      end
    end
  end
end
