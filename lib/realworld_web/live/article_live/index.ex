defmodule RealworldWeb.ArticleLive.Index do
  use RealworldWeb, :live_view

  alias Realworld.Content
  alias Realworld.Content.Article
  alias Realworld.Policy

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, _} <- Policy.authorize(Content, :list_articles, socket.assigns.current_user) do
      {:ok,
       socket
       |> stream(:articles, Content.list_articles())}
    else
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    with {:ok, article} <- Policy.authorize(Content, :update_article, socket.assigns.current_user, Content.get_article!(id)) do
      socket
      |> assign(:page_title, "Edit Article")
      |> assign(:article, article)
    else
      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
        |> push_patch(to: ~p"/articles")
    end
  end

  defp apply_action(socket, :new, _params) do
    with {:ok, article} <- Policy.authorize(Content, :create_article, socket.assigns.current_user, %Article{}) do
      socket
      |> assign(:page_title, "New Article")
      |> assign(:article, article)
    else
      {:error, reason} ->
        socket |> put_flash(:error, reason) |> push_patch(to: ~p"/articles")
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Articles")
    |> assign(:article, nil)
  end

  @impl true
  def handle_info({RealworldWeb.ArticleLive.FormComponent, {:saved, article}}, socket) do
    {:noreply, stream_insert(socket, :articles, article)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, article} <- Policy.authorize(Content, :delete_article, socket.assigns.current_user, Content.get_article!(id)) do
      {:ok, _} = Content.delete_article(article)
      {:noreply, stream_delete(socket, :articles, article)}
    else
      {:error, reason} ->
        {:noreply, socket |> put_flash(:error, reason) |> push_navigate(to: ~p"/articles")}
    end
  end
end
