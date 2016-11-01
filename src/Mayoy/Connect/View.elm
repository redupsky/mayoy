module Mayoy.Connect.View exposing (view)

import Html exposing (div, text, form, label, input)
import Html.Attributes exposing (class, disabled, type', name, value, placeholder)
import Html.Events exposing (onClick, onInput, onSubmit)
import Mayoy.Model exposing (Connection(Connecting), localhost, defaultPort)
import Mayoy.Connect.Message exposing (Message(Connect, ChangeFormHost, ChangeFormPort, ChangeFormUser, ChangeFormPassword))
import Mayoy.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo)
import Mayoy.Connect.Model exposing (formToConnectionParameters)


view model =
    div [ class "connect" ]
        [ viewErrors model.errors
        , viewConnect model
        ]


viewErrors errors =
    div [] (List.map text errors)


viewConnect { connection, form } =
    let
        isConnecting =
            case connection of
                Connecting _ ->
                    True

                _ ->
                    False
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
                    , class "connect-form-input _port"
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
                    , class "connect-form-input _port"
                    , name "password"
                    , value form.password
                    , onInput ChangeFormPassword
                    ]
                    []
                ]
            , div [ class "connect-form-item _connect" ]
                [ buttonWithIndicator
                    [ disabled isConnecting
                    , onClick <| Connect <| formToConnectionParameters form
                    ]
                    [ text "Connect.." ]
                    (rightOrNo isConnecting)
                ]
            ]
