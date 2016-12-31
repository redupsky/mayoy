module Mayoy.App.Model exposing (Model(ConnectModel, WorkspaceModel), init)

import Mayoy.App.Message
import Mayoy.Connect.Model as Connect
import Mayoy.Workspace.Model as Workspace


type Model
    = ConnectModel Connect.Model
    | WorkspaceModel Workspace.Model


init : ( Model, Cmd Mayoy.App.Message.Message )
init =
    let
        ( model, cmd ) =
            Connect.init
    in
        ( ConnectModel model, cmd )
