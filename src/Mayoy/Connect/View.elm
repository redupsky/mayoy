module Mayoy.Connect.View exposing (view)

import Html exposing (div, text, form, label, input, ul, li, h1, header)
import Html.Attributes exposing (class, disabled, type', name, value, placeholder)
import Html.Events exposing (onClick, onInput, onSubmit, onWithOptions)
import Json.Decode
import Mayoy.Model exposing (Connection(Connecting), defaultHost, defaultPort, connectionShortName)
import Mayoy.Connect.Message exposing (Message(Connect, ChangeForm, ChangeFormHost, ChangeFormPort, ChangeFormUser, ChangeFormPassword))
import Mayoy.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo)
import Mayoy.Connect.Model exposing (formToConnectionParameters, connectionParametersToForm)


view model =
    div [ class "connection" ]
        [ viewErrors model.errors
        , viewHeader
        , viewConnect model
          --, viewHistory model.history
        ]


viewErrors errors =
    let
        item error =
            li [ class "connection-errors-item" ] [ text error ]
    in
        ul [ class "connection-errors" ] (List.map item errors)


viewHeader =
    header [ class "connection-header" ] [ text "Connect to..." ]


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
        div [ class "connection-form-container" ]
            [ Html.form [ class "connection-form", onSubmit <| Connect <| formToConnectionParameters form ]
                [ div [ class "connection-form-item" ]
                    [ label [ class "connection-form-label" ] [ text "Host:" ]
                    , input
                        [ type' "text"
                        , class "connection-form-input _host"
                        , name "host"
                        , value form.host
                        , placeholder defaultHost
                        , onInput ChangeFormHost
                        ]
                        []
                    ]
                , div [ class "connection-form-item" ]
                    [ label [ class "connection-form-label" ] [ text "Port:" ]
                    , input
                        [ type' "text"
                        , class "connection-form-input _port"
                        , name "port"
                        , value form.portNumber
                        , placeholder <| toString defaultPort
                        , onInput ChangeFormPort
                        ]
                        []
                    ]
                , div [ class "connection-form-item" ]
                    [ label [ class "connection-form-label" ] [ text "User:" ]
                    , input
                        [ type' "text"
                        , class "connection-form-input _user"
                        , name "user"
                        , value form.user
                        , onInput ChangeFormUser
                        ]
                        []
                    ]
                , div [ class "connection-form-item" ]
                    [ label [ class "connection-form-label" ] [ text "Password:" ]
                    , input
                        [ type' "password"
                        , class "connection-form-input _password"
                        , name "password"
                        , value form.password
                        , onInput ChangeFormPassword
                        ]
                        []
                    ]
                , div [ class "connection-form-item _connect" ]
                    [ buttonWithIndicator
                        [ disabled isConnecting
                        , onClickWithPrevent <| Connect <| formToConnectionParameters form
                        ]
                        [ text "Connect" ]
                        (rightOrNo isConnecting)
                    ]
                ]
            ]


viewHistory connections =
    let
        item n connection =
            li
                [ onClick <| ChangeForm <| connectionParametersToForm connection
                , class "connection-history-list-item"
                ]
                [ text <| connectionShortName connection ]
    in
        if List.length connections > 0 then
            div [ class "connection-history" ]
                [ div [ class "connection-history-list-container" ]
                    [ ul [ class "connection-history-list" ] <| List.indexedMap item connections
                    ]
                , div [ class "connection-history-link" ] [ text "Press ⌘ for history" ]
                ]
        else
            text ""
