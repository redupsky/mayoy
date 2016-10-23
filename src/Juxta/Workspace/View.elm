module Juxta.Workspace.View exposing (view)

import Html exposing (div, text, textarea, header, select, option, table, thead, th, tbody, tr, td)
import Html.Attributes exposing (id, class, disabled)
import Html.Events exposing (onClick)
import String
import Juxta.Model exposing (Connection(Closing), QueryResult(Rows), queryIsRunning, connectionName, extractParamsAndThreadId)
import Juxta.Component.ButtonWithIndicator exposing (buttonWithIndicator, leftOrNo, rightOrNo)
import Juxta.Workspace.Message exposing (Message(RunQuery, CloseConnection))


textAreaId =
    "editor"


view model =
    div [ class "workspace" ]
        [ viewErrors model.errors
        , viewHeader model
        , viewQuery model.editorValue
        , viewResultTable model.result
        , viewStatus model.status
        ]


viewErrors errors =
    div [] (List.map text errors)


viewHeader { connection, result, editorValue } =
    let
        closing =
            case connection of
                Closing _ ->
                    True

                _ ->
                    False

        maybeConnectionAndThreadId =
            extractParamsAndThreadId <| connection

        name =
            case maybeConnectionAndThreadId of
                Just ( params, _ ) ->
                    connectionName params

                _ ->
                    ""

        threadId =
            case maybeConnectionAndThreadId of
                Just ( _, threadId ) ->
                    threadId

                _ ->
                    0

        selectConnection =
            div [ class "header-menu-item select-connection" ]
                [ select []
                    [ option [] [ text name ]
                    ]
                ]

        closeConnection =
            div [ class "header-menu-item close" ]
                [ buttonWithIndicator [ disabled <| closing || queryIsRunning result, onClick <| CloseConnection <| threadId ]
                    [ text "Close"
                    ]
                    (rightOrNo closing)
                ]
    in
        header [ class "header" ]
            [ div [ class "header-menu" ]
                [ selectConnection
                , closeConnection
                ]
            , div [ class "header-buttons" ]
                [ div [ class "header-buttons-item _run" ]
                    [ buttonWithIndicator [ disabled <| closing || queryIsRunning result || String.isEmpty editorValue, onClick RunQuery ] [ text "Run" ] (leftOrNo <| queryIsRunning result)
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
