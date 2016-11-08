module Mayoy.Connect.Update exposing (update)

import Mayoy.Connect.Message exposing (Message(..))
import Mayoy.Model exposing (Connection(Connecting, Established, Failed))
import Mayoy.App.Port exposing (connect)


update msg model =
    let
        form =
            model.form
    in
        case msg of
            Connect connection ->
                ( { model | errors = [], connection = Connecting connection }, connect connection )

            ConnectionEstablished ( connection, threadId ) ->
                ( { model | connection = Established ( connection, threadId ) }, Cmd.none )

            ConnectionFailed error ->
                ( { model | errors = [ error ], connection = Failed ( error, 0 ) }, Cmd.none )

            ChangeFormHost host ->
                ( { model | form = { form | host = host } }, Cmd.none )

            ChangeFormPort portNumber ->
                ( { model | form = { form | portNumber = portNumber } }, Cmd.none )

            ChangeFormUser user ->
                ( { model | form = { form | user = user } }, Cmd.none )

            ChangeFormPassword password ->
                ( { model | form = { form | password = password } }, Cmd.none )

            ReceiveConnectionHistory connections ->
                ( { model | history = connections }, Cmd.none )
