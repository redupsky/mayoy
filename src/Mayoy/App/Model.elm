module Mayoy.App.Model exposing (Model(ConnectModel, WorkspaceModel), init)

import Mayoy.Connect.Model as Connect
import Mayoy.Workspace.Model as Workspace


type Model
    = ConnectModel Connect.Model
    | WorkspaceModel Workspace.Model


init =
    let
        ( model, cmd ) =
            Connect.init
    in
        ( ConnectModel model, cmd )
