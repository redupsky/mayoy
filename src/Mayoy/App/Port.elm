port module Mayoy.App.Port exposing (..)

import Mayoy.Model exposing (Connection(..), ConnectionParameters, ThreadId, QueryResult(..), Result, Column, Row, establishedToClosing)
import Time exposing (Time)


port connect : ConnectionParameters -> Cmd msg


port connectionEstablished : (( ConnectionParameters, ThreadId ) -> msg) -> Sub msg


port connectionFailed : (String -> msg) -> Sub msg


port close : ThreadId -> Cmd msg


port connectionClosed : (ThreadId -> msg) -> Sub msg


port closeConnectionFailed : (( ThreadId, String ) -> msg) -> Sub msg


port saveConnectionParamsToLocalStorage : ( String, ConnectionParameters ) -> Cmd msg


port getConnectionHistoryFromLocalStorage : () -> Cmd msg


port receiveConnectionHistoryFromLocalStorage : (List ConnectionParameters -> msg) -> Sub msg


port changeTitle : String -> Cmd msg


port getEditorLastValueFromLocalStorage : String -> Cmd msg


port receiveEditorLastValueFromLocalStorage : (String -> msg) -> Sub msg


port runCodemirror : String -> Cmd msg


port receiveTextFromCodemirror : (String -> msg) -> Sub msg


port selectText : (Maybe String -> msg) -> Sub msg


port receiveTextInCurrentLineFromCodemirror : (Maybe String -> msg) -> Sub msg


port runQuery : ( ThreadId, String ) -> Cmd msg


port queryFailed : (( ThreadId, String ) -> msg) -> Sub msg


port receiveColumns : (( ThreadId, List Column ) -> msg) -> Sub msg


port receiveRow : (( ThreadId, Row ) -> msg) -> Sub msg


port receiveResult : (( ThreadId, Mayoy.Model.Result ) -> msg) -> Sub msg


port receiveEnd : (( ThreadId, Time ) -> msg) -> Sub msg


port pressRunInCodemirror : (String -> msg) -> Sub msg
