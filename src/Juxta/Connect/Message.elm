module Juxta.Connect.Message exposing (..)

import Juxta.Model exposing (ConnectionParameters, ThreadId)


type Message
    = Connect ConnectionParameters
    | ConnectionEstablished ( ConnectionParameters, ThreadId )
    | ConnectionFailed String
