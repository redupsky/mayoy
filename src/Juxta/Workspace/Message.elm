module Juxta.Workspace.Message exposing (..)

import Juxta.Model exposing (ThreadId, Row, Column)
import Time exposing (Time)


type Message
    = ReceiveValueFromEditor String
    | RunQuery
    | QueryFailed ( ThreadId, String )
    | ReceiveColumns ( ThreadId, List Column )
    | ReceiveRow ( ThreadId, Row )
    | ReceiveResult ( ThreadId, Juxta.Model.Result )
    | ReceiveEnd ( ThreadId, Time )
    | CountQueryExecutionTime Time
    | CloseConnection ThreadId
    | ConnectionClosed ThreadId
    | CloseConnectionFailed ( ThreadId, String )
