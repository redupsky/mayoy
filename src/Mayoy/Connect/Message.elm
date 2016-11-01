module Mayoy.Connect.Message exposing (Message(..))

import Mayoy.Model exposing (ConnectionParameters, ThreadId)


type Message
    = Connect ConnectionParameters
    | ConnectionEstablished ( ConnectionParameters, ThreadId )
    | ConnectionFailed String
    | ChangeFormHost String
    | ChangeFormPort String
    | ChangeFormUser String
    | ChangeFormPassword String
