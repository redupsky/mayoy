module Mayoy.App.View exposing (view)

import Mayoy.App.Message exposing (Message(ConnectMessage, WorkspaceMessage))
import Mayoy.App.Model exposing (Model(ConnectModel, WorkspaceModel))
import Mayoy.Connect.View as Connect
import Mayoy.Workspace.View as Workspace
import Html
import Html.App


view : Model -> Html.Html Message
view model =
    case model of
        ConnectModel model ->
            Html.App.map (\msg -> ConnectMessage msg) <| Connect.view model

        WorkspaceModel model ->
            Html.App.map (\msg -> WorkspaceMessage msg) <| Workspace.view model
