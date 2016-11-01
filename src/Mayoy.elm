module Mayoy exposing (..)

import Html.App
import Mayoy.App.Model exposing (init)
import Mayoy.App.Update exposing (update)
import Mayoy.App.View exposing (view)
import Mayoy.App.Subscriptions exposing (subscriptions)


main =
    Html.App.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
