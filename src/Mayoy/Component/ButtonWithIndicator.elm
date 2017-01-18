module Mayoy.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo, leftOrNo)

import Html exposing (button)
import Html.Attributes exposing (class)


type Indicator
    = NoIndicator
    | IndicatorOnTheLeft
    | IndicatorOnTheRight


rightOrNo : Bool -> Indicator
rightOrNo param =
    if param then
        IndicatorOnTheRight
    else
        NoIndicator


leftOrNo : Bool -> Indicator
leftOrNo param =
    if param then
        IndicatorOnTheLeft
    else
        NoIndicator


buttonWithIndicator : List (Html.Attribute a) -> List (Html.Html a) -> Indicator -> Html.Html a
buttonWithIndicator attrs childs which =
    let
        indicatorType =
            case which of
                IndicatorOnTheLeft ->
                    " _left"

                IndicatorOnTheRight ->
                    " _right"

                NoIndicator ->
                    ""
    in
        button (attrs ++ [ class <| "button-with-indicator" ++ indicatorType ]) childs
