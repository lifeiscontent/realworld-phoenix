defmodule RealworldWeb.ArticleLiveTest do
  use RealworldWeb.ConnCase

  import Phoenix.LiveViewTest
  import Realworld.ContentFixtures
  import Realworld.AccountsFixtures

  @create_attrs %{
    body: "some body",
    description: "some description",
    slug: "some-slug",
    title: "some title"
  }
  @update_attrs %{
    body: "some updated body",
    description: "some updated description",
    slug: "some-updated-slug",
    title: "some updated title"
  }
  @invalid_attrs %{body: nil, description: nil, slug: nil, title: nil}

  setup context do
    author = if context[:with_author] || context[:logged_in_as] == :author, do: user_fixture(), else: nil
    user = if context[:with_user] || context[:logged_in_as] == :user, do: user_fixture(), else: nil
    conn = case context[:logged_in_as] do
      :author -> log_in_user(context[:conn], author)
      :user -> log_in_user(context[:conn], user)
      _ -> context[:conn]
    end
    article = if context[:with_article], do: article_fixture(author: author), else: nil

    {:ok, %{article: article, author: author, conn: conn}}
  end

  describe "Index" do
    @tag :with_article
    test "lists all articles", %{conn: conn, article: article} do
      {:ok, _index_live, html} = live(conn, ~p"/articles")

      assert html =~ "Listing Articles"
      assert html =~ article.description
    end

    @tag logged_in_as: :user
    test "saves new article", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      assert index_live |> element("a", "New Article") |> render_click() =~
               "New Article"

      assert_patch(index_live, ~p"/articles/new")

      assert index_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#article-form", article: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/articles")

      html = render(index_live)
      assert html =~ "Article created successfully"
      assert html =~ "some description"
    end

    @tag logged_in_as: :author
    @tag :with_article
    test "updates article in listing", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      assert index_live |> element("#articles-#{article.id} a", "Edit") |> render_click() =~
               "Edit Article"

      assert_patch(index_live, ~p"/articles/#{article}/edit")

      assert index_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#article-form", article: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/articles")

      html = render(index_live)
      assert html =~ "Article updated successfully"
      assert html =~ "some updated description"
    end

    @tag logged_in_as: :author
    @tag :with_article
    test "deletes article in listing", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      assert index_live |> element("#articles-#{article.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#articles-#{article.id}")
    end
  end


  describe "Show" do
    @tag :with_article
    test "displays article", %{conn: conn, article: article} do
      {:ok, _show_live, html} = live(conn, ~p"/articles/#{article}")

      assert html =~ "Show Article"
      assert html =~ article.description
    end

    @tag logged_in_as: :author
    @tag :with_article
    test "updates article within modal", %{conn: conn, article: article} do
      {:ok, show_live, _html} = live(conn, ~p"/articles/#{article}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Article"

      assert_patch(show_live, ~p"/articles/#{article}/show/edit")

      assert show_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#article-form", article: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/articles/#{article}")

      html = render(show_live)
      assert html =~ "Article updated successfully"
      assert html =~ "some updated description"
    end
  end

  describe "Authorization" do
    @tag :with_article
    test "can view article when not logged in", %{conn: conn, article: article} do
      {:ok, _live, html} = live(conn, ~p"/articles/#{article}")

      assert html =~ article.title
      assert html =~ article.body
    end

    test "cannot create article when not logged in", %{conn: conn} do
      assert {:error,
              {:live_redirect,
               %{
                 to: "/articles",
                 flash: %{"error" => :unauthorized}
               }}} =
               live(conn, ~p"/articles/new")
    end

    @tag logged_in_as: :user
    @tag :with_article
    test "cannot edit other user's article", %{conn: conn, article: article} do
      # Precompute the expected redirect path
      show_path = ~p"/articles/#{article}"

      # Attempt to view the article and ensure the "Edit article" link is not present
      {:ok, show_live, _html} = live(conn, show_path)
      refute show_live |> element("a", "Edit article") |> has_element?()

      # Attempt to directly access the edit URL
      assert {:error,
              {:live_redirect,
               %{
                 to: ^show_path,
                 flash: %{"error" => :unauthorized}
               }}} =
               live(conn, ~p"/articles/#{article}/show/edit")
    end

    @tag logged_in_as: :user
    @tag :with_article
    test "cannot delete other user's article", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      assert index_live |> element("#articles-#{article.id}") |> has_element?()
      refute index_live |> element("#articles-#{article.id} a", "Delete") |> has_element?()
    end

    @tag logged_in_as: :user
    @tag :with_article
    test "cannot delete unauthorized article via event", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      # Simulate delete event directly
      assert {:error,
      {:live_redirect,
       %{
         kind: :push,
         to: "/articles",
         flash: _
       }}} = render_click(index_live, "delete", id: article.id)
    end

    @tag logged_in_as: :user
    @tag :with_article
    test "unauthorized article update via form component", %{conn: conn, article: article} do
      {:ok, show_live, _html} = live(conn, ~p"/articles/#{article}")

      # Simulate article update via form component
      send(show_live.pid, {RealworldWeb.ArticleLive.FormComponent, {:saved, article}})

      assert render(show_live) =~ "unauthorized"
    end

    test "unauthorized article creation", %{conn: conn} do
      assert {:error,
      {:live_redirect,
       %{to: "/articles", flash: %{"error" => :unauthorized}}}} =
               live(conn, ~p"/articles/new")
    end
  end
end
