module Juxta.Component.ButtonWithIndicator exposing (buttonWithIndicator, rightOrNo, leftOrNo)

import Html exposing (button)
import Html.Attributes exposing (class)


type Indicator
    = NoIndicator
    | IndicatorOnTheLeft
    | IndicatorOnTheRight


rightOrNo param =
    if param then
        IndicatorOnTheRight
    else
        NoIndicator


leftOrNo param =
    if param then
        IndicatorOnTheLeft
    else
        NoIndicator


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
