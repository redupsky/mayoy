module Mayoy.App.Update exposing (update)

import Mayoy.App.Message exposing (Message(ConnectMessage, WorkspaceMessage))
import Mayoy.App.Model exposing (Model(ConnectModel, WorkspaceModel))
import Mayoy.App.Port exposing (saveConnectionParamsToLocalStorage, changeTitle, runCodemirror)
import Mayoy.Connect.Message
import Mayoy.Connect.Model
import Mayoy.Connect.Update as Connect
import Mayoy.Workspace.Update as Workspace
import Mayoy.Workspace.Message
import Mayoy.Workspace.Model
import Mayoy.Model exposing (Connection(Established), connectionName)


textAreaId =
    "editor"


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        ConnectMessage (Mayoy.Connect.Message.ConnectionEstablished ( params, threadId )) ->
            let
                ( mod, _ ) =
                    Mayoy.Workspace.Model.init <| Established ( params, threadId )

                name =
                    connectionName params
            in
                ( WorkspaceModel mod
                , Cmd.batch
                    [ saveConnectionParamsToLocalStorage ( name, params )
                    , changeTitle name
                    , runCodemirror textAreaId
                    ]
                )

        WorkspaceMessage (Mayoy.Workspace.Message.ConnectionClosed threadId) ->
            let
                ( model, message ) =
                    Mayoy.Connect.Model.init
            in
                ( ConnectModel model, message )

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
