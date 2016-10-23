module Juxta.App.Message exposing (..)

import Juxta.Connect.Message as Connect
import Juxta.Workspace.Message as Workspace


type Message
    = ConnectMessage Connect.Message
    | WorkspaceMessage Workspace.Message
