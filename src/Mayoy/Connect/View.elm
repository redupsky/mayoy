module Mayoy.Connect.View exposing (view)

import Html exposing (div, text, form, label, input, ul, li, h1)
import Html.Attributes exposing (class, disabled, type', name, value, placeholder)
import Html.Events exposing (onClick, onInput, onSubmit, onWithOptions)
import Json.Decode
import Mayoy.Model exposing (Connection(Connecting), localhost, defaultPort, connectionName)
import Mayoy.Connect.Message exposing (Message(Connect, ChangeForm, ChangeFormHost, ChangeFormPort, ChangeFormUser, ChangeFormPassword))
import Mayoy.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo)
import Mayoy.Connect.Model exposing (formToConnectionParameters, connectionParametersToForm)


view model =
    div [ class "connect" ]
        [ viewErrors model.errors
        , viewConnect model
        , viewHistory model.history
        ]


viewErrors errors =
    let
        item error =
            li [ class "connect-errors-item" ] [ text error ]
    in
        ul [ class "connect-errors" ] (List.map item errors)


viewConnect { connection, form } =
    let
        isConnecting =
            case connection of
                Connecting _ ->
                    True

                _ ->
                    False

        defaultEventOptions =
            Html.Events.defaultOptions

        onClickWithPrevent msg =
            onWithOptions "click" { defaultEventOptions | preventDefault = True } (Json.Decode.succeed msg)
    in
        Html.form [ class "connect-form", onSubmit <| Connect <| formToConnectionParameters form ]
            [ div [ class "connect-form-item" ]
                [ label [ class "connect-form-label" ] [ text "Host:" ]
                , input
                    [ type' "text"
                    , class "connect-form-input _host"
                    , name "host"
                    , value form.host
                    , onInput ChangeFormHost
                    ]
                    []
                ]
            , div [ class "connect-form-item" ]
                [ label [ class "connect-form-label" ] [ text "Port:" ]
                , input
                    [ type' "text"
                    , class "connect-form-input _port"
                    , name "port"
                    , value form.portNumber
                    , placeholder <| toString defaultPort
                    , onInput ChangeFormPort
                    ]
                    []
                ]
            , div [ class "connect-form-item" ]
                [ label [ class "connect-form-label" ] [ text "User:" ]
                , input
                    [ type' "text"
                    , class "connect-form-input _user"
                    , name "user"
                    , value form.user
                    , onInput ChangeFormUser
                    ]
                    []
                ]
            , div [ class "connect-form-item" ]
                [ label [ class "connect-form-label" ] [ text "Password:" ]
                , input
                    [ type' "password"
                    , class "connect-form-input _password"
                    , name "password"
                    , value form.password
                    , onInput ChangeFormPassword
                    ]
                    []
                ]
            , div [ class "connect-form-item _connect" ]
                [ buttonWithIndicator
                    [ disabled isConnecting
                    , onClickWithPrevent <| Connect <| formToConnectionParameters form
                    ]
                    [ text "Connect" ]
                    (rightOrNo isConnecting)
                ]
            ]


viewHistory connections =
    let
        item n connection =
            li
                [ onClick <| ChangeForm <| connectionParametersToForm connection
                , class "connection-history-list-item"
                ]
                [ label [ class "connection-history-list-item-label" ] [ text ("⌘" ++ toString (n + 1)) ]
                , text <| connectionName connection
                ]
    in
        if List.length connections > 0 then
            div [ class "connection-history" ]
                [ h1 [ class "connection-history-header" ] [ text "History" ]
                , ul [ class "connection-history-list" ] <| List.indexedMap item connections
                ]
        else
            text ""
