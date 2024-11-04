# frozen_string_literal: true

require "spec_helper"

describe "Assembly members" do
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, :with_content_blocks, organization:, blocks_manifests:, private_space: true) }
  let(:privatable_to) { assembly }
  let(:blocks_manifests) { [] }

  let(:user) { create(:user, organization: privatable_to.organization) }
  let(:ceased_user) { create(:user, organization: privatable_to.organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no assembly members and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly) }
    end
  end

  context "when there are no assembly members and accessing from the assembly homepage" do
    context "and the main data content block is disabled" do
      it "the menu nav is not shown" do
        visit decidim_assemblies.assembly_path(assembly)

        expect(page).to have_no_css(".participatory-space__nav-container")
      end
    end

    context "and the main data content block is enabled" do
      let(:blocks_manifests) { ["main_data"] }

      it "the menu link is not shown" do
        visit decidim_assemblies.assembly_path(assembly)

        expect(page).to have_no_content("Private participants")
      end
    end
  end

  context "when the assembly does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly_slug: 999_999_999) }
    end
  end

  context "when there are some assembly members and all are unpublished" do
    before do
      create(:participatory_space_private_user, user:, privatable_to:, published: false)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly) }
      end
    end

    context "and accessing from the homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit decidim_assemblies.assembly_path(assembly)

          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is not shown" do
          visit decidim_assemblies.assembly_path(assembly)

          expect(page).to have_no_content("Private participants")
        end
      end
    end
  end

  context "when there are some published assembly members" do
    let!(:private_user) { create(:participatory_space_private_user, user:, privatable_to:, published: true) }
    let!(:ceased_private_user) { create(:participatory_space_private_user, user: ceased_user, privatable_to:, published: false) }

    before do
      visit decidim_assemblies.assembly_assembly_members_path(assembly)
    end

    context "and accessing from the assembly homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit decidim_assemblies.assembly_path(assembly)

          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is shown" do
          visit decidim_assemblies.assembly_path(assembly)

          within ".participatory-space__nav-container" do
            expect(page).to have_content("Private participants")
            click_on "Private participants"
          end

          expect(page).to have_current_path decidim_assemblies.assembly_assembly_members_path(assembly)
        end
      end

      it "lists all the non ceased assembly members" do
        within "#assembly_members-grid" do
          expect(page).to have_css(".profile__user", count: 1)

          expect(page).to have_no_content(Decidim::ParticipatorySpacePrivateUserPresenter.new(ceased_private_user).name)
        end
      end
    end
  end
end
