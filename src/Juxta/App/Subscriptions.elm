module Juxta.App.Subscriptions exposing (subscriptions)

import Juxta.App.Message exposing (Message(ConnectMessage, WorkspaceMessage))
import Juxta.App.Model exposing (Model(WorkspaceModel))
import Juxta.Connect.Message as Connect
import Juxta.Workspace.Message as Workspace
import Juxta.App.Port exposing (..)
import Time exposing (Time, second)
import Juxta.Model exposing (QueryResult(Running))


subscriptions model =
    Sub.batch
        [ connectionEstablished (ConnectMessage << Connect.ConnectionEstablished)
        , connectionFailed (ConnectMessage << Connect.ConnectionFailed)
        , connectionClosed (WorkspaceMessage << Workspace.ConnectionClosed)
        , closeConnectionFailed (WorkspaceMessage << Workspace.CloseConnectionFailed)
        , pressRunInCodemirror (WorkspaceMessage << \_ -> Workspace.RunQuery)
        , receiveTextFromCodemirror (WorkspaceMessage << Workspace.ReceiveValueFromEditor)
        , queryFailed (WorkspaceMessage << Workspace.QueryFailed)
        , receiveColumns (WorkspaceMessage << Workspace.ReceiveColumns)
        , receiveRow (WorkspaceMessage << Workspace.ReceiveRow)
        , receiveResult (WorkspaceMessage << Workspace.ReceiveResult)
        , receiveEnd (WorkspaceMessage << Workspace.ReceiveEnd)
        , (case model of
            WorkspaceModel model ->
                case model.result of
                    Just (Running passed) ->
                        Time.every second (\time -> WorkspaceMessage <| Workspace.CountQueryExecutionTime (passed + second))

                    _ ->
                        Sub.none

            _ ->
                Sub.none
          )
        ]
