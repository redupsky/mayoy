module Juxta exposing (..)

import Html.App
import Juxta.App.Model exposing (init)
import Juxta.App.Update exposing (update)
import Juxta.App.View exposing (view)
import Juxta.App.Subscriptions exposing (subscriptions)


main =
    Html.App.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
