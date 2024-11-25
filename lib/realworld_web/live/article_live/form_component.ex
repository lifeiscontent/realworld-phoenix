defmodule RealworldWeb.ArticleLive.FormComponent do
  use RealworldWeb, :live_component

  alias Realworld.Content
  alias Realworld.Policy

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage article records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="article-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:body]} type="text" label="Body" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Article</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{article: article} = assigns, socket) do
    changeset = Content.change_article(article)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"article" => article_params}, socket) do
    changeset =
      socket.assigns.article
      |> Content.change_article(article_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"article" => article_params}, socket) do
    save_article(socket, socket.assigns.action, article_params)
  end

  defp save_article(socket, :edit, article_params) do
    with {:ok, article} <- Policy.authorize(Content, :update_article, socket.assigns.current_user, socket.assigns.article),
         {:ok, article} <- Content.update_article(article, article_params) do
      notify_parent({:saved, article})

      {:noreply,
       socket
       |> put_flash(:info, "Article updated successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, message} when is_binary(message) ->
        {:noreply,
         socket
         |> put_flash(:error, message)
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp save_article(socket, :new, article_params) do
    with {:ok, _} <- Policy.authorize(Content, :create_article, socket.assigns.current_user),
         params = Map.put(article_params, "author_id", socket.assigns.current_user.id),
         {:ok, article} <- Content.create_article(params) do
      notify_parent({:saved, article})

      {:noreply,
       socket
       |> put_flash(:info, "Article created successfully")
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, message} when is_binary(message) ->
        {:noreply,
         socket
         |> put_flash(:error, message)
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
