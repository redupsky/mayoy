module Juxta.Connect.View exposing (view)

import Html exposing (div, text, input)
import Html.Attributes exposing (class, disabled, type', name, value, placeholder)
import Html.Events exposing (onClick, onInput)
import Juxta.Model exposing (Connection(Connecting), localhost, defaultPort)
import Juxta.Connect.Message exposing (Message(Connect, ChangeFormHost, ChangeFormPort, ChangeFormUser, ChangeFormPassword))
import Juxta.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo)
import Juxta.Connect.Model exposing (formToConnectionParameters)


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
        div []
            [ div [ class "connect-form" ]
                [ div []
                    [ input [ type' "text", name "host", value form.host, onInput ChangeFormHost ] []
                    ]
                , div []
                    [ input [ type' "text", name "port", value form.portNumber, placeholder <| toString defaultPort, onInput ChangeFormPort ] []
                    ]
                , div []
                    [ input [ type' "text", name "user", value form.user, onInput ChangeFormUser ] []
                    ]
                , div []
                    [ input [ type' "password", name "password", value form.password, onInput ChangeFormPassword ] []
                    ]
                , buttonWithIndicator [ disabled isConnecting, onClick <| Connect <| formToConnectionParameters form ] [ text "Connect.." ] (rightOrNo isConnecting)
                ]
            ]
