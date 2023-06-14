module Data.User exposing (User, UserToken, encodeToken, tokenDecoder)

import Iso8601
import Json.Decode as Decode
import Json.Encode as Json
import Time


type alias UserToken =
    { authToken : String
    , expiration : Time.Posix
    }


type alias UserInfo =
    {}


type alias User =
    { info : UserInfo
    , tokenInfo : UserToken
    }


encodeToken :
    { a | authToken : String, expiration : Time.Posix }
    -> Json.Value
encodeToken { authToken, expiration } =
    Json.object
        [ ( "authToken", Json.string authToken )
        , ( "expiration", Iso8601.encode expiration )
        ]


tokenDecoder : Decode.Decoder UserToken
tokenDecoder =
    Decode.map2 UserToken
        (Decode.field "authToken" Decode.string)
        (Decode.field "expiration" Iso8601.decoder)
