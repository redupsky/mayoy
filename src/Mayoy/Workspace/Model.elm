module Mayoy.Workspace.Model exposing (Model, init)

import Mayoy.Model exposing (Connection(NoConnection), QueryResult)


type alias Model =
    { errors : List String
    , connection : Connection
    , editorValue : String
    , result : Maybe QueryResult
    , status : String
    }


init connection =
    ( Model [] connection "" Nothing "", Cmd.none )
