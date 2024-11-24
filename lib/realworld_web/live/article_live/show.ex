defmodule RealworldWeb.ArticleLive.Show do
  use RealworldWeb, :live_view

  alias Realworld.Content
  alias Realworld.Policy

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    with {:ok, article} <- Policy.authorize(Content, :read_article, socket.assigns.current_user, Content.get_article!(id)) do
       socket
       |> assign(:page_title, "Show Article")
       |> assign(:article, article)
    else
      {:error, reason} ->
         socket
         |> put_flash(:error, reason)
         |> push_navigate(to: ~p"/articles")
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    article = Content.get_article!(id)
    with {:ok, article} <- Policy.authorize(Content, :update_article, socket.assigns.current_user, article) do
      socket
      |> assign(:page_title, "Edit Article")
      |> assign(:article, article)
    else
      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
        |> push_patch(to: ~p"/articles/#{article}")
    end
  end


  @impl true
  def handle_info({RealworldWeb.ArticleLive.FormComponent, {:saved, article}}, socket) do
    with {:ok, article} <- Policy.authorize(Content, :update_article, socket.assigns.current_user, article) do
      {:noreply,
       socket
       |> assign(:article, article)
       |> put_flash(:info, "Article updated successfully")
       |> push_patch(to: ~p"/articles/#{article}")}
    else
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)
         |> push_patch(to: ~p"/articles/#{article}")}
    end
  end
end
