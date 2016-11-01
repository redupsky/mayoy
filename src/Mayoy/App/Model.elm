module Mayoy.App.Model exposing (Model(ConnectModel, WorkspaceModel), init)

import Mayoy.Connect.Model as Connect
import Mayoy.Workspace.Model as Workspace


type Model
    = ConnectModel Connect.Model
    | WorkspaceModel Workspace.Model


init =
    let
        ( model, _ ) =
            Connect.init
    in
        ( ConnectModel model, Cmd.none )
