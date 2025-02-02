# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_system_overrides: "#{base_path}/app/packs/entrypoints/decidim_system_overrides.scss",
  decidim_system: "#{base_path}/app/packs/entrypoints/decidim_system.js"
)
