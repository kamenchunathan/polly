port module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , User
    , init
    , subscriptions
    , update
    )

import Iso8601
import Json.Decode as Decode
import Json.Encode as Json
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


encodeUser : { a | authToken : String, expiration : Time.Posix } -> Json.Value
encodeUser { authToken, expiration } =
    Json.object
        [ ( "authToken", Json.string authToken )
        , ( "expiration", Iso8601.encode expiration )
        ]


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map2 User
        (Decode.field "authToken" Decode.string)
        (Decode.field "expiration" Iso8601.decoder)


init : Request -> Flags -> ( Model, Cmd Msg )
init _ flags =
    ( { -- TODO: Handle errors from decoding better
        user =
            Result.toMaybe (Decode.decodeValue userDecoder flags)
      }
    , Cmd.none
    )


type Msg
    = Signin
        { authToken : String
        , expiration : Time.Posix
        }


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg _ =
    case msg of
        Signin user ->
            ( { user = Just user }, persistUserToLocalStorage (encodeUser user) )


port persistUserToLocalStorage : Json.Value -> Cmd msg


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
