defmodule RealworldWeb.LayoutsTest do
  use RealworldWeb.ConnCase, async: true

  alias RealworldWeb.Layouts

  test "renders app layout with no user", %{conn: _conn} do
    assigns = %{
      flash: %{},
      live_action: :index,
      current_user: nil,
      inner_content: "test content"
    }

    rendered = Layouts.app(assigns)

    # Check for static elements
    content = rendered.static |> Enum.join("")
    assert content =~ "GitHub"
    assert content =~ "@elixirphoenix"
    assert content =~ "Get Started"
    assert content =~ "<img"
    assert content =~ "v"
  end

  test "renders app layout with user", %{conn: _conn} do
    assigns = %{
      flash: %{info: "Test flash"},
      live_action: :index,
      current_user: %{email: "test@example.com"},
      inner_content: "test content"
    }

    rendered = Layouts.app(assigns)

    # Check for static elements
    content = rendered.static |> Enum.join("")
    assert content =~ "GitHub"
    assert content =~ "@elixirphoenix"
    assert content =~ "Get Started"
    assert content =~ "<img"
    assert content =~ "v"
  end

  test "renders root layout with no user", %{conn: _conn} do
    assigns = %{
      csrf_token: Phoenix.Controller.get_csrf_token(),
      inner_content: "test content",
      current_user: nil,
      page_title: "Test Page"
    }

    rendered = Layouts.root(assigns)

    content = rendered.static |> Enum.join("")
    # Check for static elements
    assert content =~ "<!DOCTYPE html>"
    assert content =~ "<meta charset=\"utf-8\""
    assert content =~ "csrf-token"
    assert content =~ "<html lang=\"en\""
    assert content =~ "viewport"
  end

  test "renders root layout with user", %{conn: _conn} do
    assigns = %{
      csrf_token: Phoenix.Controller.get_csrf_token(),
      inner_content: "test content",
      current_user: %{email: "test@example.com"},
      page_title: "Test Page"
    }

    rendered = Layouts.root(assigns)

    content = rendered.static |> Enum.join("")
    # Check for static elements
    assert content =~ "<!DOCTYPE html>"
    assert content =~ "<meta charset=\"utf-8\""
    assert content =~ "csrf-token"
    assert content =~ "<html lang=\"en\""
    assert content =~ "viewport"
  end
end
