module Mayoy.App.Message exposing (Message(..))

import Mayoy.Connect.Message as Connect
import Mayoy.Workspace.Message as Workspace


type Message
    = ConnectMessage Connect.Message
    | WorkspaceMessage Workspace.Message
