module Mayoy.Workspace.View exposing (view)

import Html exposing (div, text, textarea, header, select, option, table, thead, th, tbody, tr, td, ul, li)
import Html.Attributes exposing (class, disabled, id)
import Html.Events exposing (onClick)
import String
import Mayoy.Model exposing (Connection(Closing), QueryResult(Rows), queryIsRunning, connectionShortName, extractParamsAndThreadId)
import Mayoy.Component.ButtonWithIndicator exposing (buttonWithIndicator, leftOrNo, rightOrNo)
import Mayoy.Workspace.Message exposing (Message(Run, CloseConnection))


textAreaId =
    "editor"


view model =
    div [ class "workspace" ]
        ((viewErrors model.errors)
            ++ [ viewHeader model
               , viewQuery model.editor.value
               , viewResultTable model.result
               , viewStatus model.status
               ]
        )


viewErrors errors =
    let
        elems =
            case errors of
                [] ->
                    []

                errors ->
                    errors |> List.map (\error -> li [ class "workspace-errors-list-item" ] [ text error ])
    in
        [ ul [ class "workspace-errors-list" ] elems ]


viewHeader { connection, result, editor } =
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
                    connectionShortName params

                _ ->
                    ""

        threadId =
            case maybeConnectionAndThreadId of
                Just ( _, threadId ) ->
                    threadId

                _ ->
                    0
    in
        header [ class "header" ]
            [ div [ class "header-menu _left" ] []
            , div [ class "header-title" ] [ text name ]
            , div [ class "header-menu _right" ]
                [ div [ class "header-menu-item" ]
                    [ buttonWithIndicator [ disabled <| closing || queryIsRunning result || String.isEmpty editor.value, onClick Run ] [ text "Run" ] (leftOrNo <| queryIsRunning result)
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
