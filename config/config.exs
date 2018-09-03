# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :ex_fussball_de_scraper, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:ex_fussball_de_scraper, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :ex_fussball_de_scraper, :css,
  team_name: ".stage-team h2",
  matches: "#id-team-matchplan-table tbody tr",
  matches_match_headline: "td:first-child",
  matches_match_headline_splitter: "|",
  matches_match_club_names: "td.column-club .club-name",
  current_table: "#team-fixture-league-tables > table"

config :ex_fussball_de_scraper, :url,
  scheme: "https",
  host: "www.fussball.de",
  path_regex: ~r/\/mannschaft\/(?<team_rewrite>[^\/]+)\/-\/saison\/(?<saison>\d\d\d\d)\/team-id\/(?<team_id>[^\/]+)(#!(?<fragment>[^\/]+))*/
