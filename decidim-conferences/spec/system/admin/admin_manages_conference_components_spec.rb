# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference components" do
  include_context "when admin administrating a conference"

  it_behaves_like "manage conference components"

  describe "Soft delete" do
    let(:admin_resource_path) { decidim_admin_conferences.components_path(conference) }
    let(:trash_path) { decidim_admin_conferences.deleted_components_path(conference) }
    let(:title) { { en: "My component" } }
    let!(:resource) { create(:component, manifest_name: "proposals", participatory_space: conference, deleted_at:, name: title) }

    it_behaves_like "manage soft deletable component or space", "component"
    it_behaves_like "manage trashed resource", "component"
  end
end
