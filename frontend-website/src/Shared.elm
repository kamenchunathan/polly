port module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Data.User exposing (User, encodeToken, tokenDecoder)
import Json.Decode as Decode
import Json.Encode as Json
import Request exposing (Request)
import Time


type alias Flags =
    Json.Value


type alias Model =
    { user : Maybe User }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ flags =
    ( { -- TODO: Handle errors from decoding better
        user =
            Result.toMaybe (Decode.decodeValue tokenDecoder flags)
                |> Maybe.map (User {})
      }
    , Cmd.none
    )


type Msg
    = PerformLogin
        { authToken : String
        , expiration : Time.Posix
        }
    | PerformLogout


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg _ =
    case msg of
        PerformLogin authToken ->
            ( { user = Just (User {} authToken) }
            , persistUserToLocalStorage (encodeToken authToken)
            )

        PerformLogout ->
            ( { user = Nothing }
            , clearUserFromLocalStorage ()
            )


port persistUserToLocalStorage : Json.Value -> Cmd msg


port clearUserFromLocalStorage : () -> Cmd msg


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
