module Juxta.App.Update exposing (update)

import Juxta.App.Message exposing (Message(ConnectMessage, WorkspaceMessage))
import Juxta.App.Model exposing (Model(ConnectModel, WorkspaceModel))
import Juxta.App.Port exposing (runCodemirror)
import Juxta.Connect.Message
import Juxta.Connect.Model
import Juxta.Connect.Update as Connect
import Juxta.Workspace.Update as Workspace
import Juxta.Workspace.Message
import Juxta.Workspace.Model
import Juxta.Model exposing (Connection(Established))


textAreaId =
    "editor"


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        ConnectMessage (Juxta.Connect.Message.ConnectionEstablished ( params, threadId )) ->
            let
                ( mod, _ ) =
                    Juxta.Workspace.Model.init <| Established ( params, threadId )
            in
                ( WorkspaceModel mod, runCodemirror textAreaId )

        WorkspaceMessage (Juxta.Workspace.Message.ConnectionClosed threadId) ->
            let
                ( mod, _ ) =
                    Juxta.Connect.Model.init
            in
                ( ConnectModel mod, Cmd.none )

        ConnectMessage connectMessage ->
            case model of
                ConnectModel connectModel ->
                    let
                        ( updatedModel, newMessage ) =
                            Connect.update connectMessage connectModel
                    in
                        ( ConnectModel updatedModel, Cmd.map ConnectMessage newMessage )

                _ ->
                    ( model, Cmd.none )

        WorkspaceMessage workspaceMessage ->
            case model of
                WorkspaceModel workspaceModel ->
                    let
                        ( updatedModel, newMessage ) =
                            Workspace.update workspaceMessage workspaceModel
                    in
                        ( WorkspaceModel updatedModel, Cmd.map WorkspaceMessage newMessage )

                _ ->
                    ( model, Cmd.none )
