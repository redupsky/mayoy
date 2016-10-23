module Juxta.App.View exposing (view)

import Juxta.App.Message exposing (Message(ConnectMessage, WorkspaceMessage))
import Juxta.App.Model exposing (Model(ConnectModel, WorkspaceModel))
import Juxta.Connect.View as Connect
import Juxta.Workspace.View as Workspace
import Html.App


view model =
    case model of
        ConnectModel model ->
            Html.App.map (\msg -> ConnectMessage msg) <| Connect.view model

        WorkspaceModel model ->
            Html.App.map (\msg -> WorkspaceMessage msg) <| Workspace.view model
