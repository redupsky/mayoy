module Mayoy.Connect.Message exposing (Message(..))

import Mayoy.Model exposing (ConnectionParameters, ThreadId)
import Mayoy.Connect.Model exposing (Form)


type Message
    = Connect ConnectionParameters
    | ConnectionEstablished ( ConnectionParameters, ThreadId )
    | ConnectionFailed String
    | ChangeForm Form
    | ChangeFormHost String
    | ChangeFormPort String
    | ChangeFormUser String
    | ChangeFormPassword String
    | ReceiveConnectionHistory (List ConnectionParameters)
