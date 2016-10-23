module Juxta.App.Model exposing (Model(ConnectModel, WorkspaceModel), init)

import Juxta.Connect.Model as Connect
import Juxta.Workspace.Model as Workspace


type Model
    = ConnectModel Connect.Model
    | WorkspaceModel Workspace.Model


init =
    let
        ( model, _ ) =
            Connect.init
    in
        ( ConnectModel model, Cmd.none )
