port module Juxta exposing (..)

import Html exposing (text, div, span, textarea, button, table, tr, td, tbody, thead, select, option, header, main')
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


port runCodemirror : String -> Cmd msg


port requestTextFromCodemirror : String -> Cmd msg


port connect : ConnectionParameters -> Cmd msg


port connectionEstablished : (ConnectionParameters -> msg) -> Sub msg


port connectionFailed : (String -> msg) -> Sub msg


port pressRunInCodemirror : (String -> msg) -> Sub msg


port receiveTextFromCodemirror : (String -> msg) -> Sub msg


subscriptions model =
    Sub.batch
        [ connectionEstablished ConnectionEstablished
        , connectionFailed ConnectionFailed
        , pressRunInCodemirror (\_ -> TryToRun)
        , receiveTextFromCodemirror ReceiveTextAndRun
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
    , results : List Query
    , status : String
    }


type alias Query =
    ( String, Maybe Result )


type Result
    = List String


init =
    ( Model [] NoConnection "select * from mysql.tables where name like '%mysql%'" [] ""
    , Cmd.none
    )



-- Update


type Message
    = Connect ConnectionParameters
    | ConnectionFailed String
    | ConnectionEstablished ConnectionParameters
    | TryToRun
    | ReceiveTextAndRun String
    | RunCommand


update msg model =
    case msg of
        Connect connection ->
            ( { model | errors = [], connection = Connecting connection }, connect connection )

        ConnectionFailed error ->
            ( { model | errors = [ error ], connection = Failed ( error, 0 ) }, Cmd.none )

        ConnectionEstablished connection ->
            ( { model | connection = Established ( connection, 0 ) }, runCodemirror textAreaId )

        ReceiveTextAndRun text ->
            update RunCommand { model | text = text }

        RunCommand ->
            ( { model | status = "Run: " ++ model.text }, Cmd.none )

        TryToRun ->
            ( model, requestTextFromCodemirror "" )



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
    main' []
        [ viewErrors model.errors
        , viewHeader model
        , viewQuery model.text
        , viewResultTable model.results
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
    in
        header [ class "header" ]
            [ div [ class "header-left" ]
                [ select []
                    [ option [] [ text connectionName ]
                    ]
                ]
            , div [ class "header-right" ]
                [ button [ class "query-run-button", onClick TryToRun ] [ text "Run" ]
                ]
            ]


viewQuery queries =
    div [ class "query" ]
        [ textarea [ class "query-text", id textAreaId ] [ text queries ]
        ]


viewResultTable results =
    if List.length results > 0 then
        table [ class "results-table" ]
            [ tbody []
                [ tr []
                    [ td []
                        [ text "Qq"
                        ]
                    , td []
                        [ text "zZ.."
                        ]
                    ]
                ]
            ]
    else
        div []
            [ text "Not results yet"
            ]


viewStatus status =
    div [ class "status" ]
        [ text status
        ]
