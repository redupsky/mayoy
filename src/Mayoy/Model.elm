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


queryIsRunning : Maybe QueryResult -> Bool
queryIsRunning result =
    case result of
        Just (Running _) ->
            True

        _ ->
            False


connectionName : ConnectionParameters -> String
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


connectionShortName : ConnectionParameters -> String
connectionShortName { user, hostAndPort } =
    let
        ( host, portNumber ) =
            hostAndPort

        at =
            if user == "" then
                ""
            else
                "@"

        portOrEmptyString =
            if portNumber == defaultPort then
                ""
            else
                ":" ++ (toString portNumber)
    in
        user ++ at ++ host ++ portOrEmptyString


extractParamsAndThreadId : Connection -> Maybe ( ConnectionParameters, ThreadId )
extractParamsAndThreadId connection =
    case connection of
        Established ( params, threadId ) ->
            Just ( params, threadId )

        Closing ( params, threadId ) ->
            Just ( params, threadId )

        _ ->
            Nothing


establishedToClosing : Connection -> Connection
establishedToClosing connection =
    case connection of
        Established connection ->
            Closing connection

        _ ->
            NoConnection



-- Defaults


defaultHost : String
defaultHost =
    "localhost"


defaultPort : Int
defaultPort =
    3306
