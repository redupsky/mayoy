module Juxta.Connect.Model exposing (Model, init)

import Juxta.Model exposing (Connection(NoConnection))


type alias Model =
    { errors : List String
    , connection : Connection
    }


init =
    ( Model [] NoConnection, Cmd.none )
