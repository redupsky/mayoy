module Mayoy.Connect.Model exposing (Model, init, Form, formToConnectionParameters, connectionParametersToForm)

import String
import Mayoy.Model exposing (Connection(NoConnection), ConnectionParameters, defaultPort)
import Mayoy.App.Port exposing (getConnectionHistoryFromLocalStorage, changeTitle)


type alias Model =
    { errors : List String
    , connection : Connection
    , form : Form
    , history : List ConnectionParameters
    }


type alias Form =
    { host : String
    , portNumber : String
    , user : String
    , password : String
    , database : String
    }


emptyForm =
    Form "" "" "" "" ""


formToConnectionParameters { host, portNumber, user, password, database } =
    let
        portNumberInt =
            case String.toInt portNumber of
                Ok number ->
                    number

                Err _ ->
                    defaultPort
    in
        ConnectionParameters ( host, portNumberInt ) user password Nothing


connectionParametersToForm { hostAndPort, user, password, database } =
    let
        host =
            fst hostAndPort

        port' =
            toString <| snd hostAndPort

        database' =
            case database of
                Just database ->
                    database

                Nothing ->
                    ""
    in
        Form host port' user password database'


init =
    ( Model [] NoConnection emptyForm []
    , Cmd.batch
        [ changeTitle "Connect to..."
        , getConnectionHistoryFromLocalStorage ()
        ]
    )
