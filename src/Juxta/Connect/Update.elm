module Juxta.Connect.Update exposing (update)

import Juxta.Connect.Message exposing (Message(..))
import Juxta.Model exposing (Connection(Connecting, Established, Failed))
import Juxta.App.Port exposing (connect)


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
                Debug.log "" ( { model | form = { form | host = host } }, Cmd.none )

            ChangeFormPort portNumber ->
                ( { model | form = { form | portNumber = portNumber } }, Cmd.none )

            ChangeFormUser user ->
                ( { model | form = { form | user = user } }, Cmd.none )

            ChangeFormPassword password ->
                ( { model | form = { form | password = password } }, Cmd.none )
