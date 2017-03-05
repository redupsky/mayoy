module Mayoy.Connect.Model exposing (Model, init, Form, formToConnectionParameters, connectionParametersToForm)

import String
import Mayoy.Model exposing (Connection(NoConnection), ConnectionParameters, defaultHost, defaultPort)
import Mayoy.App.Port exposing (getConnectionHistoryFromLocalStorage, changeTitle)


type alias Model =
    { errors : List String
    , connection : Connection
    , form : Form
    , history : List ConnectionParameters
    , showHistory : Bool
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
        hostOrDefault =
            case host of
                "" ->
                    defaultHost

                _ ->
                    host

        portOrDefault =
            case String.toInt portNumber of
                Ok number ->
                    number

                Err _ ->
                    defaultPort
    in
        ConnectionParameters ( hostOrDefault, portOrDefault ) user password Nothing


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
    ( Model [] NoConnection emptyForm [] False
    , Cmd.batch
        [ changeTitle "Connect to..."
        , getConnectionHistoryFromLocalStorage ()
        ]
    )
