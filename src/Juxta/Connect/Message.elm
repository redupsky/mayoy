module Juxta.Connect.Message exposing (Message(..))

import Juxta.Model exposing (ConnectionParameters, ThreadId)


type Message
    = Connect ConnectionParameters
    | ConnectionEstablished ( ConnectionParameters, ThreadId )
    | ConnectionFailed String
    | ChangeFormHost String
    | ChangeFormPort String
    | ChangeFormUser String
    | ChangeFormPassword String
