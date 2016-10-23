module Juxta.Connect.Update exposing (update)

import Juxta.Connect.Message exposing (Message(Connect, ConnectionEstablished, ConnectionFailed))
import Juxta.Model exposing (Connection(Connecting, Established, Failed))
import Juxta.App.Port exposing (connect)


update msg model =
    case msg of
        Connect connection ->
            ( { model | errors = [], connection = Connecting connection }, connect connection )

        ConnectionEstablished ( connection, threadId ) ->
            ( { model | connection = Established ( connection, threadId ) }, Cmd.none )

        ConnectionFailed error ->
            ( { model | errors = [ error ], connection = Failed ( error, 0 ) }, Cmd.none )
