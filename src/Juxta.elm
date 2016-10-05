port module Juxta exposing (..)

import Html exposing (text, div, span, textarea, button, table, th, tr, td, tbody, thead, select, option, header)
import Html.Attributes exposing (style, class, id, disabled)
import Html.Events exposing (onInput, onClick, on, keyCode)
import Html.App as App
import Json.Decode


textAreaId =
    "editor"


main =
    App.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }



-- Subscriptions


port connect : ConnectionParameters -> Cmd msg


port connectionEstablished : (( ConnectionParameters, ThreadId ) -> msg) -> Sub msg


port connectionFailed : (String -> msg) -> Sub msg


port close : ThreadId -> Cmd msg


port connectionClosed : (ThreadId -> msg) -> Sub msg


port closeConnectionFailed : (( ThreadId, String ) -> msg) -> Sub msg


port runCodemirror : String -> Cmd msg


port requestTextFromCodemirror : String -> Cmd msg


port receiveTextFromCodemirror : (String -> msg) -> Sub msg


port runQuery : ( ThreadId, String ) -> Cmd msg


port queryFailed : (( ThreadId, String ) -> msg) -> Sub msg


port receiveColumns : (( ThreadId, List Column ) -> msg) -> Sub msg


port receiveRow : (( ThreadId, Row ) -> msg) -> Sub msg


port receiveResult : (( ThreadId, Result ) -> msg) -> Sub msg


port receiveEnd : (ThreadId -> msg) -> Sub msg


port pressRunInCodemirror : (String -> msg) -> Sub msg


subscriptions model =
    Sub.batch
        [ connectionEstablished ConnectionEstablished
        , connectionFailed ConnectionFailed
        , pressRunInCodemirror (\_ -> TryToRun)
        , receiveTextFromCodemirror ReceiveTextAndRun
        , connectionClosed ConnectionClosed
        , closeConnectionFailed CloseConnectionFailed
        , queryFailed QueryFailed
        , receiveColumns ReceiveColumns
        , receiveRow ReceiveRow
        , receiveResult ReceiveResult
        , receiveEnd ReceiveEnd
        ]



-- Model


type alias ConnectionParameters =
    { hostAndPort : ( String, Int )
    , user : String
    , password : String
    , database : Maybe String
    }


type alias ConnectionError =
    ( String, Int )


type alias ThreadId =
    Int


type Connection
    = NoConnection
    | Connecting ConnectionParameters
    | Failed ConnectionError
    | Established ( ConnectionParameters, ThreadId )


localhost =
    ConnectionParameters ( "localhost", 3306 ) "root" "" Nothing


type alias Model =
    { errors : List String
    , connection : Connection
    , text : String
    , result : Maybe QueryResult
    , status : String
    }


type alias Query =
    String


type QueryResult
    = Ok Result
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


init =
    ( Model [] NoConnection "select * from `tables` where name like '%mysql%';" Nothing ""
    , Cmd.none
    )



-- Update


type Message
    = Connect ConnectionParameters
    | ConnectionFailed String
    | ConnectionEstablished ( ConnectionParameters, ThreadId )
    | CloseConnection ThreadId
    | CloseConnectionFailed ( ThreadId, String )
    | ConnectionClosed ThreadId
    | TryToRun
    | ReceiveTextAndRun String
    | RunQuery
    | QueryFailed ( ThreadId, String )
    | ReceiveColumns ( ThreadId, List Column )
    | ReceiveRow ( ThreadId, Row )
    | ReceiveResult ( ThreadId, Result )
    | ReceiveEnd ThreadId


update msg model =
    case msg of
        Connect connection ->
            ( { model | errors = [], connection = Connecting connection, status = "" }, connect connection )

        ConnectionFailed error ->
            ( { model | errors = [ error ], connection = Failed ( error, 0 ) }, Cmd.none )

        ConnectionEstablished ( connection, threadId ) ->
            ( { model | connection = Established ( connection, threadId ) }, runCodemirror textAreaId )

        CloseConnection threadId ->
            ( { model | errors = [] }, close threadId )

        CloseConnectionFailed ( threadId, error ) ->
            ( { model | connection = NoConnection, errors = [ error ] }, Cmd.none )

        ConnectionClosed threadId ->
            ( { model | connection = NoConnection }, Cmd.none )

        TryToRun ->
            ( model, requestTextFromCodemirror "" )

        ReceiveTextAndRun text ->
            update RunQuery { model | text = text }

        RunQuery ->
            ( { model | errors = [], status = "" }
            , case model.connection of
                Established ( _, threadId ) ->
                    runQuery ( threadId, model.text )

                _ ->
                    Cmd.none
            )

        QueryFailed ( _, error ) ->
            ( { model | errors = [ error ], result = Just <| QueryFails <| error }, Cmd.none )

        ReceiveColumns ( _, columns ) ->
            ( { model | result = Just <| Rows ( columns, [] ) }, Cmd.none )

        ReceiveRow ( _, row ) ->
            case model.result of
                Just (Rows ( columns, rows )) ->
                    ( { model | result = Just (Rows ( columns, rows ++ [ row ] )) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReceiveResult ( _, result ) ->
            ( { model | result = Just <| Ok <| result }, Cmd.none )

        ReceiveEnd _ ->
            let
                status result =
                    case result of
                        Just (Ok result) ->
                            "Query OK, " ++ toString result.affectedRows ++ " rows affected, " ++ toString result.warningCount ++ " warning"

                        Just (Rows ( _, [] )) ->
                            "Empty set"

                        Just (Rows ( _, [ _ ] )) ->
                            "1 row in set"

                        Just (Rows ( _, rows )) ->
                            let
                                length =
                                    List.length rows
                            in
                                toString length ++ " rows" ++ " in set"

                        Just (QueryFails _) ->
                            "Errors"

                        _ ->
                            ""
            in
                ( { model | status = status model.result }, Cmd.none )



-- View


view model =
    case model.connection of
        Established _ ->
            viewWorkspace model

        _ ->
            viewLogin model


viewLogin model =
    let
        isConnecting =
            case model.connection of
                Connecting _ ->
                    True

                _ ->
                    False
    in
        div []
            [ viewErrors model.errors
            , button [ onClick <| Connect <| localhost, disabled isConnecting ] [ text "Connect.." ]
            ]


viewWorkspace model =
    div [ class "workspace" ]
        [ viewErrors model.errors
        , viewHeader model
        , viewQuery model.text
        , viewResultTable model.result
        , viewStatus model.status
        ]


viewErrors errors =
    div [] (List.map text errors)


viewHeader model =
    let
        connectionName =
            case model.connection of
                Established ( { user, hostAndPort }, _ ) ->
                    let
                        host =
                            fst hostAndPort

                        portNumber =
                            snd hostAndPort
                    in
                        user ++ "@" ++ host ++ ":" ++ (toString portNumber)

                _ ->
                    ""

        connectionThreadId =
            case model.connection of
                Established ( _, threadId ) ->
                    threadId

                _ ->
                    0
    in
        header [ class "header" ]
            [ div [ class "header-menu" ]
                [ div [ class "header-menu-item select-connection" ]
                    [ select []
                        [ option [] [ text connectionName ]
                        ]
                    ]
                , div [ class "header-menu-item close" ]
                    [ button [ class "close-button", onClick <| CloseConnection <| connectionThreadId ] [ text "Close" ] ]
                ]
            , div [ class "header-buttons" ]
                [ div []
                    [ button [ onClick TryToRun ] [ text "Run" ]
                    ]
                ]
            ]


viewQuery queries =
    div [ class "editor" ]
        [ textarea [ id textAreaId ] [ text queries ]
        ]


viewResultTable result =
    let
        head columns =
            case columns of
                [] ->
                    []

                columns ->
                    [ thead [] (List.map (\c -> th [] [ text c.name ]) columns) ]

        body rows =
            case rows of
                [] ->
                    []

                rows ->
                    [ tbody []
                        (List.map (\row -> tr [] (List.map (\( _, value ) -> td [] [ text value ]) row)) rows)
                    ]

        columnsAndRows columns rows =
            table [ class "grid visible" ]
                ((head columns)
                    ++ (body rows)
                )
    in
        case result of
            Just (Rows ( columns, rows )) ->
                div [ class "grid-container" ]
                    [ columnsAndRows columns rows
                    ]

            _ ->
                text ""


viewStatus status =
    div [ class "status-bar" ]
        [ div [ class "status-bar-left" ]
            [ text status
            ]
        , div [ class "status-bar-right" ] [ text "UTF-8" ]
        ]
