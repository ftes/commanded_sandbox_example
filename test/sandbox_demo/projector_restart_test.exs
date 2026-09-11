defmodule SandboxDemo.ProjectorRestartTest do
  use SandboxDemo.DataCase, async: true

  alias SandboxDemo.Articles.Projector

  test "a restarted projector receives SQL and Mimic allowances again", %{
    commanded_supervisor: supervisor
  } do
    author = SandboxDemo.create_author("Alice")
    assert :ok = SandboxDemo.subscribe()

    first_id = Ecto.UUID.generate()

    assert :ok =
             SandboxDemo.publish_article(%{
               article_id: first_id,
               author_id: author.id,
               title: "Before",
               body: "One"
             })

    assert_receive {:article_published, ^first_id}

    {child_id, old_pid, :worker, _} =
      supervisor
      |> Supervisor.which_children()
      |> Enum.find(fn {_, _, _, modules} -> Projector in modules end)

    :ok = Supervisor.terminate_child(supervisor, child_id)
    {:ok, new_pid} = Supervisor.restart_child(supervisor, child_id)
    refute new_pid == old_pid
    assert_receive {_ready_ref, ^new_pid}, 5_000

    second_id = Ecto.UUID.generate()

    assert :ok =
             SandboxDemo.publish_article(%{
               article_id: second_id,
               author_id: author.id,
               title: "After",
               body: "Two"
             })

    assert_receive {:article_published, ^second_id}
    assert Enum.map(SandboxDemo.list_articles(), & &1.title) == ["After", "Before"]
  end
end
