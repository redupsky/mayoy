module Juxta.Workspace.Update exposing (update)

import Juxta.Workspace.Message exposing (..)
import Juxta.Model exposing (QueryResult(..), Connection(..), establishedToClosing)
import Juxta.App.Port exposing (close, runQuery)
import Time exposing (second)
import String


update msg model =
    case msg of
        ReceiveValueFromEditor value ->
            ( { model | editorValue = value }, Cmd.none )

        RunQuery ->
            let
                runQueryIfEstablished =
                    case model.connection of
                        Established ( _, threadId ) ->
                            runQuery ( threadId, model.editorValue )

                        _ ->
                            Cmd.none
            in
                if String.isEmpty model.editorValue then
                    ( model, Cmd.none )
                else
                    ( { model | errors = [], result = Just <| Running 0, status = "" }
                    , runQueryIfEstablished
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
            ( { model | result = Just <| Juxta.Model.Ok <| result }, Cmd.none )

        ReceiveEnd ( _, duration ) ->
            let
                result =
                    case model.result of
                        Just (Juxta.Model.Ok result) ->
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
