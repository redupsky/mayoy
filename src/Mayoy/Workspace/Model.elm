module Mayoy.Workspace.Model exposing (Model, init)

import Mayoy.Model exposing (Connection(NoConnection), QueryResult)


type alias Editor =
    { value : String
    , selection : Maybe String
    , queryInCurrentLine : Maybe String
    }


type alias Model =
    { errors : List String
    , connection : Connection
    , editor : Editor
    , result : Maybe QueryResult
    , status : String
    }


init connection =
    ( Model [] connection (Editor "" Nothing Nothing) Nothing "", Cmd.none )
