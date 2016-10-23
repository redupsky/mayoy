module Juxta.Connect.View exposing (view)

import Html exposing (div, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)
import Juxta.Model exposing (Connection(Connecting), localhost)
import Juxta.Connect.Message exposing (Message(Connect))
import Juxta.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo)


view model =
    div [ class "connect" ]
        [ viewErrors model.errors
        , viewConnect model
        ]


viewErrors errors =
    div [] (List.map text errors)


viewConnect model =
    let
        isConnecting =
            case model.connection of
                Connecting _ ->
                    True

                _ ->
                    False
    in
        div []
            [ div [ class "connect-form" ]
                [ buttonWithIndicator [ onClick <| Connect localhost, disabled isConnecting ] [ text "Connect.." ] (rightOrNo isConnecting)
                ]
            ]
