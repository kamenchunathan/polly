module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , User
    , init
    , subscriptions
    , update
    )

import Json.Decode as Json
import Request exposing (Request)
import Time


type alias Flags =
    Json.Value


type alias User =
    { authToken : String
    , expiration : Time.Posix
    }


type alias Model =
    { user : Maybe User }


type Msg
    = Signin
        { authToken : String
        , expiration : Time.Posix
        }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( { user = Nothing }, Cmd.none )


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg _ =
    case msg of
        Signin user ->
            -- TODO: persist user data
            ( { user = Just user }, Cmd.none )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
