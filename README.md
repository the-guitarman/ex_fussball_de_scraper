[![Build Status](https://travis-ci.org/the-guitarman/ex_fussball_de_scraper.svg?branch=master)](https://travis-ci.org/the-guitarman/ex_fussball_de_scraper)
[![Code Climate](https://codeclimate.com/github/the-guitarman/ex_fussball_de_scraper/badges/gpa.svg)](https://codeclimate.com/github/the-guitarman/ex_fussball_de_scraper)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://github.com/syl20bnr/spacemacs)

# ExFussballDeScraper

This application grabs next matches and the current table from a fussball.de team website.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ex_fussball_de_scraper` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ex_fussball_de_scraper, "~> 0.1.0"}
      ]
    end
    ```

  2. Ensure `ex_fussball_de_scraper` is started before your application:

    ```elixir
    def application do
      [applications: [:ex_fussball_de_scraper]]
    end
    ```
    
### Configuration

The app has default configurations. You may overwrite it by setting some configurations:

```elixir
config :ex_fussball_de_scraper, :css,
  
```

## Usage



## License

Everything may break everytime. Therefore this package is licensed under the LGPL 3.0. Do whatever you want with it, but please give improvements and bugfixes back so everyone can benefit.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_fussball_de_scraper](https://hexdocs.pm/ex_fussball_de_scraper).

