defmodule RealworldWeb.PageHTMLTest do
  use RealworldWeb.ConnCase, async: true

  alias RealworldWeb.PageHTML

  test "renders home.html" do
    rendered = PageHTML.home(%{})
    content = rendered.static |> Enum.join("")
    assert content =~ "Peace of mind from prototype to production"
    assert content =~ "Build rich, interactive web applications"
    assert content =~ "Follow on Twitter"
    assert content =~ "Source Code"
    assert content =~ "Phoenix Framework"
    assert content =~ "text-brand mt-10 flex items-center text-sm font-semibold"
    assert content =~ "Guides &amp; Docs"
    assert content =~ "Changelog"
    assert content =~ "group relative rounded-2xl px-6 py-4 text-sm font-semibold leading-6"
    assert content =~ "https://hexdocs.pm/phoenix/overview.html"
    assert content =~ "https://github.com/phoenixframework/phoenix"
    assert content =~ "https://twitter.com/elixirphoenix"
  end
end
