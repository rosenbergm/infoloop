defmodule Infoloop.Points do
  use Ash.Api

  resources do
    resource Infoloop.Points.Assignment
    resource Infoloop.Points.Class
    resource Infoloop.Points.Completion
    resource Infoloop.Points.UserClass
  end
end
