[![Build Status](https://travis-ci.org/the-guitarman/ex_fussball_de_scraper.svg?branch=master)](https://travis-ci.org/the-guitarman/ex_fussball_de_scraper)
[![Code Climate](https://codeclimate.com/github/the-guitarman/ex_fussball_de_scraper/badges/gpa.svg)](https://codeclimate.com/github/the-guitarman/ex_fussball_de_scraper)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://github.com/syl20bnr/spacemacs)

# ExFussballDeScraper

This application grabs next matches and the current table from a fussball.de team website.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as addition `ex_fussball_de_scraper` in your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ex_fussball_de_scraper, "~> 0.1"}
      ]
    end
    ```

### Configuration

The app has default configurations:

```elixir
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
  
```

 You may overwrite it by setting some of these configurations in your project.

## Usage

To use this app you need a rewrite and an id for your team from fussball.de. Therefore go to the team website at fussball.de and have a look to the url. The format is like: http://www.fussball.de/mannschaft/<club-name-team-rewrite>/-/saison/<saison>/team-id/<team-id>#!/section/stage
Copy the values within <> and use it like so:

Receive the next matches:

```elixir
ExFussballDeScraper.Scraper.next_matches("club-name-team-rewrite", "team-id")
```

This returns a tuple:

```elixir
{:ok, %{team_name: "my team name", matches: [...]}, timestamp}
{:error, error_reason, timestamp}
```

Receive the current table 

```elixir
ExFussballDeScraper.Scraper.current_table("club-name-team-rewrite", "team-id")
```

This returns a tuple:

```elixir
{:ok, %{team_name: "my team name", current_table: html_string}, timestamp}
{:error, error_reason, timestamp}
```

## License

Everything may break everytime. Therefore this package is licensed under the LGPL 3.0. Do whatever you want with it, but please give improvements and bugfixes back so everyone can benefit.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_fussball_de_scraper](https://hexdocs.pm/ex_fussball_de_scraper).

