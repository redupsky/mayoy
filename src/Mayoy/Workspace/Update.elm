module Mayoy.Workspace.Update exposing (update)

import Mayoy.Workspace.Message exposing (..)
import Mayoy.Model exposing (QueryResult(..), Connection(..), establishedToClosing)
import Mayoy.App.Port exposing (close, runQuery)
import Time exposing (second)
import String


runQueryIfEstablished connection query =
    case connection of
        Established ( _, threadId ) ->
            runQuery ( threadId, query )

        _ ->
            Cmd.none


update msg model =
    case msg of
        ReceiveValueFromEditor value ->
            let
                editor =
                    model.editor
            in
                ( { model | editor = { editor | value = value } }, Cmd.none )

        ReceiveValueInSelectionFromEditor value ->
            let
                editor =
                    model.editor
            in
                ( { model | editor = { editor | selection = value } }, Cmd.none )

        ReceiveValueInCurrentLineFromEditor value ->
            let
                editor =
                    model.editor
            in
                ( { model | editor = { editor | queryInCurrentLine = value } }, Cmd.none )

        RunQuery query ->
            ( { model | errors = [], result = Just <| Running 0, status = "" }, runQueryIfEstablished model.connection query )

        RunAllAsQuery ->
            if String.isEmpty model.editor.value then
                ( model, Cmd.none )
            else
                update (RunQuery model.editor.value) model

        RunQueryInSelection ->
            case model.editor.selection of
                Just text ->
                    update (RunQuery text) model

                Nothing ->
                    ( model, Cmd.none )

        RunQueryInCurrentLine ->
            case model.editor.queryInCurrentLine of
                Just text ->
                    update (RunQuery text) model

                Nothing ->
                    ( model, Cmd.none )

        Run ->
            case model.editor.selection of
                Just _ ->
                    update RunQueryInSelection model

                Nothing ->
                    update RunQueryInCurrentLine model

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
            ( { model | result = Just <| Mayoy.Model.Ok <| result }, Cmd.none )

        ReceiveEnd ( _, duration ) ->
            let
                result =
                    case model.result of
                        Just (Mayoy.Model.Ok result) ->
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

                timing =
                    "(" ++ toString duration ++ " sec)"
            in
                ( { model | status = result ++ " " ++ timing }, Cmd.none )

        CountQueryExecutionTime time ->
            ( { model
                | result = Just <| Running time
                , status =
                    if time >= second then
                        "Waiting…"
                    else
                        ""
              }
            , Cmd.none
            )

        CloseConnection threadId ->
            ( { model | connection = establishedToClosing model.connection, errors = [] }, close threadId )

        CloseConnectionFailed ( threadId, error ) ->
            ( { model | errors = [ error ], connection = NoConnection }, Cmd.none )

        _ ->
            ( model, Cmd.none )
