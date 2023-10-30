# frozen_string_literal: true

require "spec_helper"

describe "User closes a debate" do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debate) do
    create(
      :debate,
      author: user,
      component:
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component
    click_link debate.title.values.first
  end

  context "when closing my debate" do
    it "allows closing my debate", :slow do
      find("button[data-dialog-open='close-debate']", text: "Close debate").click

      within ".close-debate-modal" do
        fill_in :debate_conclusions, with: "Yes, all organizations should use Decidim!"
        click_button "Close debate"
      end

      expect(page).to have_content("The debate was closed")
      expect(page).to have_content("Yes, all organizations should use Decidim!")
    end
  end

  context "when the debate has been closed" do
    let!(:debate) do
      create(
        :debate,
        :closed,
        author: user,
        component:
      )
    end

    it "cannot be edited" do
      expect(page).not_to have_content("Edit debate")
    end

    it "is allowed to change the conclusions" do
      click_button "Edit conclusions"

      within ".close-debate-modal" do
        fill_in :debate_conclusions, with: "New conclusions"
        click_button "Close debate"
      end

      expect(page).to have_content("New conclusions")
    end
  end
end
