# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This class holds a Form to create/update debates from Decidim's admin panel.
      class DebateForm < Decidim::Form
        include Decidim::HasUploadValidations
        include Decidim::AttachmentAttributes
        include Decidim::TranslatableAttributes
        include Decidim::HasTaxonomyFormAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :instructions, String
        translatable_attribute :information_updates, String
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :finite, Boolean, default: true
        attribute :comments_enabled, Boolean, default: true
        attribute :attachment, AttachmentForm

        attachments_attribute :documents

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :instructions, translatable_presence: true
        validates :start_time, presence: { if: :validate_start_time? }, date: { before: :end_time, allow_blank: true, if: :validate_start_time? }
        validates :end_time, presence: { if: :validate_end_time? }, date: { after: :start_time, allow_blank: true, if: :validate_end_time? }

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          self.finite = model.start_time.present? && model.end_time.present?
          presenter = DebatePresenter.new(model)

          self.title = presenter.title(all_locales: title.is_a?(Hash))
          self.description = presenter.description(all_locales: description.is_a?(Hash))
          self.documents = model.attachments
        end

        def participatory_space_manifest
          @participatory_space_manifest ||= current_component.participatory_space.manifest.name
        end

        private

        def validate_end_time?
          finite && start_time.present?
        end

        def validate_start_time?
          end_time.present?
        end

        # This method will add an error to the `add_documents` field only if there is
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
        end
      end
    end
  end
end
