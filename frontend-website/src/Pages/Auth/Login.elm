module Pages.Auth.Login exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Config exposing (apiTokenPath, localRootUri)
import Data.User exposing (User)
import Dict
import Effect exposing (Effect)
import Gen.Params.Auth.Login exposing (Params)
import Gen.Route as Route exposing (Route(..))
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Http
import Iso8601
import Json.Decode as Decode
import Json.Encode as Encode
import Page
import RemoteData exposing (RemoteData)
import Request
import Shared
import Time exposing (Posix)
import Url
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page { user } req =
    Page.advanced
        { init = init req user
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias LoginData =
    { username : Maybe String
    , password : Maybe String
    }


type alias TokenResponse =
    { authToken : String
    , expiration : Posix
    }


type alias Model =
    { login_data : LoginData
    , response : RemoteData Http.Error TokenResponse
    , req : Request.With Params
    , current_user : Maybe User
    }


encodeLoginData :
    { a
        | username : Maybe String
        , password : Maybe String
    }
    -> Encode.Value
encodeLoginData obj =
    -- TODO: find a better way of error handling here
    Encode.object
        [ ( "username", Maybe.withDefault "" obj.username |> Encode.string )
        , ( "password", Maybe.withDefault "" obj.password |> Encode.string )
        ]


decodeTokenResponse : Decode.Decoder TokenResponse
decodeTokenResponse =
    Decode.map2
        TokenResponse
        (Decode.field "token" Decode.string)
        (Decode.field "expires" Iso8601.decoder)


init : Request.With Params -> Maybe User -> ( Model, Effect msg )
init req current_user =
    ( { login_data =
            { username = Nothing
            , password = Nothing
            }
      , response = RemoteData.NotAsked
      , req = req
      , current_user = current_user
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UpdateUsername String
    | UpdatePassword String
    | PerformLogin
    | LoginResult (RemoteData Http.Error TokenResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg ({ login_data } as model) =
    case msg of
        UpdatePassword password ->
            let
                updated_login_data =
                    { login_data | password = Just password }
            in
            ( { model
                | login_data = updated_login_data
              }
            , Effect.none
            )

        UpdateUsername username ->
            let
                updated_login_data =
                    { login_data | username = Just username }
            in
            ( { model | login_data = updated_login_data }, Effect.none )

        PerformLogin ->
            let
                req =
                    Http.post
                        { url = localRootUri ++ apiTokenPath
                        , body =
                            encodeLoginData login_data
                                |> Http.jsonBody
                        , expect =
                            Http.expectJson (RemoteData.fromResult >> LoginResult)
                                decodeTokenResponse
                        }
            in
            ( model, Effect.fromCmd req )

        LoginResult res ->
            let
                -- _ =
                --     Debug.log "" res
                redirectRoute =
                    Debug.log "Request parameters: "
                        (Dict.get "next" model.req.query
                            |> Maybe.andThen Url.fromString
                            |> Maybe.map Route.fromUrl
                            |> Maybe.withDefault Route.Home_
                        )

                login_eff =
                    case res of
                        RemoteData.Success user ->
                            Effect.batch
                                [ Shared.PerformLogin user
                                    |> Effect.fromShared
                                , Request.pushRoute redirectRoute model.req
                                    |> Effect.fromCmd
                                ]

                        _ ->
                            Effect.none
            in
            ( { model | response = res }, login_eff )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Poly | Login "
    , body =
        [ H.div [ HA.class "flex flex-col min-h-screen bg-neutral-100" ]
            [ navbar Nothing
            , login_form model
            ]
        ]
    }


login_form : Model -> Html Msg
login_form { login_data } =
    H.div
        [ HA.class "grid grow" ]
        [ H.div
            [ HA.class "mt-28 p-8 m-auto flex flex-col bg-white rounded-md" ]
            [ -- Header
              H.div
                [ HA.class "p-12 text-2xl font-extrabold text-center" ]
                [ H.text "Login" ]

            -- Login form
            , H.form
                [ HA.class "flex flex-col justify-center m-auto space-y-8"
                , HE.onSubmit PerformLogin
                ]
                [ H.div
                    []
                    [ H.label
                        [ HA.for "username-input"
                        , HA.class "px-4"
                        ]
                        [ H.text "Username" ]
                    , H.input
                        [ HA.id "username-input"
                        , HA.type_ "text"
                        , HA.class ""
                        , HA.attribute "autocomplete" "username email"
                        , HA.autofocus True
                        , HE.onInput UpdateUsername
                        , HA.value (Maybe.withDefault "" login_data.username)
                        ]
                        []
                    ]
                , H.div []
                    [ H.label
                        [ HA.for "password-input"
                        , HA.class "px-4"
                        ]
                        [ H.text "Password" ]
                    , H.input
                        [ HA.id "password-input"
                        , HA.type_ "password"
                        , HA.name "password"
                        , HA.attribute "autocomplete" "new-password"
                        , HA.class ""
                        , HE.onInput UpdatePassword
                        , HA.value (Maybe.withDefault "" login_data.password)
                        ]
                        []
                    ]
                , H.div [] []

                -- Submit
                , H.input
                    [ HA.type_ "submit"
                    , HA.value "Login"
                    , HA.class <|
                        "self-center px-4 py-1 rounded-md bg-slate-900 text-white "
                            ++ " text-lg shadow-2xl"
                    , HE.onClick PerformLogin
                    ]
                    []
                ]
            ]
        ]
