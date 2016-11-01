module Mayoy.Model exposing (..)

import Time exposing (Time)


type alias ConnectionParameters =
    { hostAndPort : ( String, Int )
    , user : String
    , password : String
    , database : Maybe String
    }


type Connection
    = NoConnection
    | Connecting ConnectionParameters
    | Established ( ConnectionParameters, ThreadId )
    | Failed ConnectionError
    | Closing ( ConnectionParameters, ThreadId )


type alias ThreadId =
    Int


type alias ConnectionError =
    ( String, Int )


type alias Query =
    String


type QueryResult
    = Running Time
    | Ok Result
    | Rows ( List Column, List Row )
    | QueryFails String


type alias Result =
    { affectedRows : Int
    , changedRows : Int
    , insertId : Int
    , message : String
    , warningCount : Int
    }


type alias Column =
    { name : String
    , typeNum : Int
    }


type alias Row =
    List ( String, String )



-- Helpers


queryIsRunning result =
    case result of
        Just (Running _) ->
            True

        _ ->
            False


connectionName params =
    let
        user =
            params.user

        host =
            fst params.hostAndPort

        portNumber =
            snd params.hostAndPort
    in
        user ++ "@" ++ host ++ ":" ++ (toString portNumber)


establishedToClosing connection =
    case connection of
        Established connection ->
            Closing connection

        _ ->
            NoConnection


extractParamsAndThreadId connection =
    case connection of
        Established ( params, threadId ) ->
            Just ( params, threadId )

        Closing ( params, threadId ) ->
            Just ( params, threadId )

        _ ->
            Nothing



--


defaultPort =
    3306


localhost =
    ConnectionParameters ( "localhost", defaultPort ) "root" "" Nothing
