module Mayoy.Workspace.Message exposing (..)

import Mayoy.Model exposing (ThreadId, Row, Column)
import Time exposing (Time)


type Message
    = ReceiveValueFromEditor String
    | ReceiveValueInSelectionFromEditor (Maybe String)
    | ReceiveValueInCurrentLineFromEditor (Maybe String)
    | ReceiveEditorLastValue String
    | RunQuery String
    | Run
    | RunAllAsQuery
    | RunQueryInSelection
    | RunQueryInCurrentLine
    | QueryFailed ( ThreadId, String )
    | ReceiveColumns ( ThreadId, List Column )
    | ReceiveRow ( ThreadId, Row )
    | ReceiveResult ( ThreadId, Mayoy.Model.Result )
    | ReceiveEnd ( ThreadId, Time )
    | CountQueryExecutionTime Time
    | CloseConnection ThreadId
    | ConnectionClosed ThreadId
    | CloseConnectionFailed ( ThreadId, String )
