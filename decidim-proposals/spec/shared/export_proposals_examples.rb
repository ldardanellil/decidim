# frozen_string_literal: true

shared_examples "export proposals" do
  let!(:proposals) { create_list(:proposal, 3, component: current_component) }

  let(:export_type) { "Export all" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"

  context "with query" do
    before do
      fill_in "q[id_string_or_title_cont]", with: translated(proposals.last.title)
      find("button[aria-label='Search']").click
    end

    let(:export_type) { "Export selection" }

    it_behaves_like "export as CSV"
    it_behaves_like "export as JSON"
  end
end

shared_examples "export as CSV" do
  it "exports a CSV" do
    expect(Decidim::PrivateExport.count).to eq(0)

    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_on "Proposals as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "proposals" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("proposals")
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    expect(Decidim::PrivateExport.count).to eq(0)

    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_on "Proposals as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "proposals" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("proposals")
  end
end
